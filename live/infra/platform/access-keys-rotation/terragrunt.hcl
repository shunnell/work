include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "${get_path_to_repo_root()}/../modules//access-key-rotation/"
}

inputs = {
  cloudwatch_schedule_exp = "cron(0 0 1 * ? *)"
  ses_email               = ["CA-CST-Cloud-City-Platform@state.gov", "CloudCityPlatformTeam@groups.state.gov"]
}
