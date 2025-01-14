# include "root" {
#   path = find_in_parent_folders("root.hcl")
# }

# terraform {
#   source = "../../../../modules//s3"
# }

# inputs = {
#   bucket_name       = "iva-bucket"
#   enable_versioning = true
# }