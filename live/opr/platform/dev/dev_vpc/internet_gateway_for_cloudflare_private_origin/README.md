# `internet_gateway_for_cloudflare_private_origin`

OPR is the sole user of a very new AWS feature, cloudfront private origin. This allows cloudfront public websites to
route to private VPCs without giving those VPCs public subnets, and without setting up NAT gateways in those public
subnets to route to a VPC's internet gateways.

This pattern *might* end up being generalized, but for now it provides a maximally secure implementation of OPR's SSP-
-approved need to have an internet presence for engineers/QA staff to test their sandbox/development applications.

# CloudFlare private origin requirements

Using VPC private origins for CloudFlare *does* require an internet gateway in the VPC, and it *does* require two things:
1. The VPC must not have a public access block (done in the adjacent `../vpc` folder).
2. Thre must be an IGW attached to the VPC. The IGW doesn't need to be routed in any way (no subnet membership or NAT gateways for it), but it needs to be there.

This module facilitates the latter goal.

# References

- https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/private-content-vpc-origins.html
- https://aws.amazon.com/blogs/networking-and-content-delivery/introducing-cloudfront-virtual-private-cloud-vpc-origins-shield-your-web-applications-from-public-internet/
