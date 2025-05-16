include "root" {
  path = find_in_parent_folders("root.hcl")
}

include "sso_resource" {
  path = "${get_repo_root()}/management/platform/sso/utilities/sso_resource.hcl"
}

terraform {
  source = "${get_path_to_repo_root()}/../modules//iam/sso_permission_set"
}

inputs = {
  permission_set_name = "Cloud_City_Ops_Monitoring"
  description         = "Cloud City Platform Operator Users"
  inline_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Resource" : ["*"],
        "Action" : [
          # Additionally, we want to let ops monitoring users create dashboards.
          # TODO grant this permission more broadly and in a way that is scoped to dashboards related to a particular
          #   permission set, by name (e.g. a pathing or tagging convention).
          "cloudwatch:PutDashboard",
          "cloudwatch:DeleteDashboards",
          "ce:GetCostAndUsage",
          "ce:GetCostForecast",
          "ce:GetReservationCoverage"
        ]
      }
    ]
  })
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/ReadOnlyAccess"
  ]
}