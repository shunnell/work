include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "${get_path_to_repo_root()}/../modules//sns"
}

inputs = {
  topic_name = "security-notifications"

  subscriptions = [
    {
      protocol = "email"
      endpoint = "OlabowalePO@state.gov"
    },
    {
      protocol = "email"
      endpoint = "AngelA@state.gov"
    },
    {
      protocol = "email"
      endpoint = "BentleyZE@state.gov"
    },
    {
      protocol = "email"
      endpoint = "BetancourtT@state.gov"
    },
    {
      protocol = "email"
      endpoint = "FrischJ@state.gov"
    },
    {
      protocol = "email"
      endpoint = "GeorgeJJ@state.gov"
    },
    {
      protocol = "email"
      endpoint = "HunnellS@state.gov"
    },
    {
      protocol = "email"
      endpoint = "TsaplaG@state.gov"
    },
    {
      protocol = "email"
      endpoint = "VusohE@state.gov"
    },
    {
      protocol = "email"
      endpoint = "WoodsD@state.gov"
    },
    {
      protocol = "email"
      endpoint = "YazidiM@state.gov"
    },
    {
      protocol = "email"
      endpoint = "SpandeN@state.gov"
    }
  ]
}
