# This file is intended to be an include in other SSO resource units.
dependency "sso_instance" {
  # NOTE: This must be `get_repo_root` and NOT `get_path_to_repo_root` in order for this to 
  # work with `expose = true` in includes. Expose = true changes the pathing such that the relative lookup
  # happens from a different place, this need to be pinned
  config_path = "${get_repo_root()}/management/platform/sso/utilities/sso_instance"
  mock_outputs = {
    arn               = "arn:aws:sso:::instance/mock123456"
    identity_store_id = "d-aaaaaaaaaa"
  }
}

inputs = {
  instance_arn      = dependency.sso_instance.outputs.arn
  identity_store_id = dependency.sso_instance.outputs.identity_store_id
  session_duration  = "PT1H"
}
