# include "root" {
#   path = find_in_parent_folders("root.hcl")
# }

# terraform {
#   source = "../../../../modules//s3"
# }

# inputs = {
#   bucket_name       = "opr-bucket"
#   enable_versioning = true
# }