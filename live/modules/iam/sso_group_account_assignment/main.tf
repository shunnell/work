# This doesn't create an SSO group
# Groups are defined in Okta and synced with Identity Store
# This `data` elements allows for looking the group up by name.
data "aws_identitystore_group" "sso_group" {
  identity_store_id = var.identity_store_id

  alternate_identifier {
    unique_attribute {
      attribute_path  = "DisplayName"
      attribute_value = var.group_display_name
    }
  }
}

# For each key-value pair
# Give the GROUP the PERMISSION SET in the ACCOUNT
resource "aws_ssoadmin_account_assignment" "this" {
  for_each = var.account_to_permission_set_map

  instance_arn       = var.instance_arn
  principal_type     = "GROUP"
  principal_id       = data.aws_identitystore_group.sso_group.group_id
  permission_set_arn = each.value
  target_type        = "AWS_ACCOUNT"
  target_id          = each.key
}