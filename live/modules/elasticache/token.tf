module "cache_auth_token" {
  source                         = "../secret"
  description                    = var.description
  name_prefix                    = "cloud-city/elasticache/${var.name}"
  tags                           = var.tags
  value                          = "youshouldreallychangethisdefaulttokentosomethingelse"
  ignore_changes_to_secret_value = true
}

data "aws_secretsmanager_secret_version" "current" {
  secret_id = module.cache_auth_token.secret_id
}
