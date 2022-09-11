terraform {
  source = "../../modules//aws"
}

include {
  path = find_in_parent_folders()
}

locals {
  aws = yamldecode(file(find_in_parent_folders("aws.yaml")))
}
