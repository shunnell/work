data "aws_ssoadmin_application" "vpn" {
  application_arn = var.application_arn
}

data "aws_identitystore_group" "sso_group" {
  identity_store_id = var.identity_store_id

  alternate_identifier {
    unique_attribute {
      attribute_path  = "DisplayName"
      attribute_value = var.group_display_name
    }
  }
}

resource "aws_ssoadmin_application_assignment" "vpn_assignment" {
  application_arn = data.aws_ssoadmin_application.vpn.application_arn
  principal_id    = data.aws_identitystore_group.sso_group.group_id
  principal_type  = "GROUP"
}