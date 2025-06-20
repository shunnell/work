from __future__ import annotations

from functools import cached_property, cache
from typing import Mapping, Iterable, Self

from bespin_tools.lib.aws.account import Account
from bespin_tools.lib.aws.dict_resource import AWSDictResource
from bespin_tools.lib.aws.util import paginate


class VPC(AWSDictResource):
    @property
    def id(self) -> str:
        return self['VpcId']

    @classmethod
    def _query(cls, account, **filters):
        for vpc in paginate(account.ec2_client().describe_vpcs, **filters):
            yield cls(account, vpc)

    def cidrs(self):
        cidrs = dict()
        for additional_cidr in self.get('CidrBlockAssociationSet', []):
            cidrs[additional_cidr['CidrBlock']] = additional_cidr['CidrBlockState']['State']
        for additional_cidr in self.get('Ipv6CidrBlockAssociationSet', []):
            cidrs[additional_cidr['Ipv6CidrBlock']] = additional_cidr['Ipv6CidrBlockState']['State']
        del cidrs[self['CidrBlock']]
        yield self['CidrBlock']
        yield from cidrs.keys()

    @cached_property
    def subnets(self) -> tuple[Subnet]:
        subnets = []
        for subnet in Subnet.query(self.account):
            if subnet['VpcId'] == self.id:
                subnets.append(subnet)
                subnets[-1].vpc = self
        return tuple(subnets)


class Subnet(AWSDictResource):
    @classmethod
    def _query(cls, account: Account, **filters) -> Iterable[Self]:
        for subnet in paginate(account.ec2_client().describe_subnets, **filters):
            yield cls(account, subnet)

    @property
    def id(self):
        return self['SubnetId']

    @cached_property
    def vpc(self) -> VPC:
        rv, = VPC.query(self.account, VpcIds=[self['VpcId']])
        return rv


class InternetGateway(AWSDictResource):
    @property
    def id(self) -> str:
        return self['InternetGatewayId']

    @classmethod
    def _query(cls, account: Account, **filters) -> Iterable[Self]:
        for igw in paginate(account.ec2_client().describe_internet_gateways, **filters):
            yield cls(account, igw)

    @cached_property
    def vpc_attachments(self) -> Mapping[VPC, str]:
        rv = dict()
        if not len(self['Attachments']):
            return rv
        vpcs = {v.id: v for v in VPC.query(self.account)}
        if any(a['VpcId'] not in vpcs for a in self['Attachments']):
            vpcs = {v.id: v for v in VPC.query()}
        for attachment in self['Attachments']:
            rv[vpcs[attachment['VpcId']]] = attachment['State']
        return rv


def _bpa_state(state: str) -> str:
    assert not state.endswith('progress'), f"VPC public access block is updating ({state}); try again in a few minutes"
    if state in ('delete-complete', 'disable-complete'):
        state = 'disabled'
    elif state.endswith('failed'):
        state = 'failed'
    if state in ('update-complete', 'create-complete', 'default-state'):
        state = 'active'
    return state

@cache
def account_blocking_public_access(account: Account) -> tuple[bool, bool]:
    settings = account.ec2_client().describe_vpc_block_public_access_options()['VpcBlockPublicAccessOptions']
    mode = settings['InternetGatewayBlockMode']
    state = _bpa_state(settings['State'])
    exclusions_allowed = settings['ExclusionsAllowed'] == 'allowed'
    return mode != 'off' and state != 'disabled', exclusions_allowed

@cache
def account_public_access_exclusions(account: Account):
    # TODO paginate once a future boto3 update supports it:
    exclusions = account.ec2_client().describe_vpc_block_public_access_exclusions(MaxResults=100)['VpcBlockPublicAccessExclusions']
    assert len(exclusions) < 100
    rv = dict()
    for exclusion in exclusions:
        _, resource_id = exclusion['ResourceArn'].split('/', 1)
        rv[resource_id] = (exclusion['InternetGatewayExclusionMode'], _bpa_state(exclusion['State']))
    return rv
