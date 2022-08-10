terraform {
  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 4.25.0"
    }
  }
  experiments = [module_variable_optional_attrs]
}
