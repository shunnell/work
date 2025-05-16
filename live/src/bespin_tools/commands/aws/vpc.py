from __future__ import annotations

import click

from bespin_tools.lib.aws.organization import Organization
from bespin_tools.lib.aws.vpc import VPC, InternetGateway, account_blocking_public_access, \
    account_public_access_exclusions
from bespin_tools.lib.tables import BespinctlTable
from bespin_tools.lib.aws.util import paginate


@click.group
def vpc():
    ...

def _ylw(item):
    return f"[yellow]{item}[/yellow]"

def _red(item):
    return f"[red]{item}[/red]"

def _grn(item):
    return f"[green]{item}[/green]"


@vpc.command(short_help="Displays a table of VPCs and their attached CIDR ranges.")
def vpcs():
    with BespinctlTable(['Account', 'CIDR', 'State', 'VPC']) as table:
        for vpc in VPC.query():
            for cidr, state in vpc.cidrs():
                table.add_row(vpc.account, cidr, state, vpc)

@vpc.command(short_help="Displays a table of subnets, their VPCs, whether or not they are public, and how many IPs are free in them.")
def subnets():
    with BespinctlTable(['Account', 'CIDR', 'MapPublicIpOnLaunch', 'Subnet', 'VPC', 'Free IPs']) as table:
        for vpc in VPC.query():
            for subnet in vpc.subnets:
                free_ips = subnet['AvailableIpAddressCount']
                if free_ips <= 3:
                    free_ips = _red(free_ips)
                elif free_ips < 100:
                    free_ips = _ylw(free_ips)
                table.add_row(
                    vpc.account,
                    subnet['CidrBlock'],
                    _red(True) if subnet['MapPublicIpOnLaunch'] else False,
                    subnet,
                    vpc,
                    free_ips,
                )

@vpc.command(short_help="Displays a table of internet gateways and the VPCs to which they are attached.")
def internet_gateways():
    red = _red('red')
    with BespinctlTable(
        ['Account', 'Gateway', 'Attachments'],
        caption = f"Internet gateways in {red} are attached to multiple VPCs; VPCs in {red} are from other AWS accounts"
    ) as table:
        for igw in InternetGateway.query():
            attachments = []
            for vpc, state in igw.vpc_attachments.items():
                attachments.append(f"{vpc if vpc.account == igw.account else _red(vpc)}:{state}")
            attachments = [vpc for vpc in igw.vpc_attachments]
            table.add_row(
                igw.account,
                _red(igw) if len(attachments) > 1 else igw,
                ', '.join(map(str, attachments)),
            )

@vpc.command(short_help="Displays a table showing a 'public access health-check' for each VPC and settings relevant to public access to it.")
def vpc_public_access_report():
    def _expect_none(items):
        if len(items) == 0:
            return _grn(0)
        return _red(len(items))

    with BespinctlTable(['Account', 'VPC', 'Internet Gateways', 'Public Subnets', 'VPC BPA', 'Account BPA']) as table:
        for vpc in VPC.query():
            account_blocking, _ = account_blocking_public_access(vpc.account)
            if not account_blocking:
                bpa_status = _red("Unrestricted")
            else:
                _, exclude_state = account_public_access_exclusions(vpc.account).get(vpc.id, (None, "disabled"))
                if exclude_state == "disabled":
                    bpa_status =_grn( "Restricted")
                else:
                    bpa_status = _ylw("Excluded")

            vpc_bpa = vpc['BlockPublicAccessStates']['InternetGatewayBlockMode']
            vpc_bpa = {'off': _red, 'block-bidirectional': _grn}.get(vpc_bpa, _ylw)(vpc_bpa)

            table.add_row(
                vpc.account,
                vpc,
                _expect_none([igw for igw in InternetGateway.query() if vpc in igw.vpc_attachments]),
                _expect_none([subnet for subnet in vpc.subnets if subnet['MapPublicIpOnLaunch']]),
                vpc_bpa,
                bpa_status,
            )

@vpc.command(short_help="Displays a table of account-wide VPC Block Public Access restrictions and exclusions to them.")
def account_block_public_access():
    with BespinctlTable(['Account', 'Type', 'Subject', 'Block status']) as table:
        for account in Organization.get_accounts(Organization.ALL):
            is_blocking, can_exclude = account_blocking_public_access(account)
            if is_blocking:
                status = _ylw("Exclusions allowed") if can_exclude else _grn("Mandatory")
            else:
                status = _red("Disabled")
            table.add_row(
                account,
                'Account',
                'all resources',
                status,
            )
            for resource, (mode, state) in account_public_access_exclusions(account).items():
                if state == "disabled":
                    state = "Exclusion Disabled (clean up)"
                elif state == "active":
                    state = _ylw(mode)
                else:
                    state = _ylw(f"{state} (mode)")
                table.add_row(account, 'Exclusion', resource, state)
@vpc.command(short_help="Displays all NACL rules allowing egress of port 22 or port 3389.")
def check_nacl_ports():
    with BespinctlTable(['Account', 'VPC-ID', 'CIDR', 'NACL-ID', 'Rule Number']) as table:
        seen = set()
        for account in Organization.get_accounts(Organization.ALL):
            nacls = list(paginate(account.ec2_client().describe_network_acls))
            for nacl in nacls:
                nacl_id = nacl['NetworkAclId']
                vpc_id = nacl['VpcId']
                for entry in nacl.get('Entries', []):
                    cidr_block = entry.get('CidrBlock')
                    if entry.get('RuleAction') == 'allow':
                        port_range = entry.get('PortRange')
                        protocol = entry.get('Protocol')
                        rule_num = entry.get('RuleNumber')

                        # https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-resource-ec2-networkaclentry.html
                        # Look under properties for PortRange and Protocol. (-1 is all protocols, 6 is TCP, and 17 is UDP)
                        if port_range and protocol in ['6', '17']:
                            from_port = port_range.get('From')
                            to_port = port_range.get('To')
                            if 22 in range(from_port, to_port + 1) or 3389 in range(from_port, to_port + 1):
                                table.add_row(account.account_name, vpc_id, cidr_block, nacl_id, rule_num)
                                
                        if protocol == '-1' and cidr_block == '0.0.0.0/0':
                            key = (account.account_name, vpc_id, cidr_block, nacl_id, rule_num)
                            if key not in seen:
                                seen.add(key)
                                table.add_row(account.account_name, vpc_id, cidr_block, nacl_id, rule_num)  
  