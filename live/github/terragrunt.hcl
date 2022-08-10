terraform {
  source = "../../modules//github"
}

include {
  path = find_in_parent_folders()
}

locals {
  github = yamldecode(file(find_in_parent_folders("github.yaml")))
}

inputs = {
  repositories = local.github.repositories
}
