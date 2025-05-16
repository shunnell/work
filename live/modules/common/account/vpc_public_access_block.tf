# Accounts block public VPC access by default; exceptions can be made for specific VPCs (in the vpc module in Terraform
# or by hand for non-TF-managed VPCs in the UI) where approved:
resource "aws_vpc_block_public_access_options" "block_public_access" {
  internet_gateway_block_mode = "block-bidirectional"
}
