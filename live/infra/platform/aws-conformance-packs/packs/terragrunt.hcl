include "root" {
  path = find_in_parent_folders("root.hcl")
}

dependency "bucket" {
  config_path = ".."
  mock_outputs = {
    bucket_id = "name"
  }
}

terraform {
  source = "."
}

inputs = {
  bucket_id = dependency.bucket.outputs.bucket_id
}
