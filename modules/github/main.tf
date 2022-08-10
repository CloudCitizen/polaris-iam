locals {
  repositories = defaults(var.repositories, {
    visibility             = "private",
    has_issues             = true,
    has_projects           = true,
    has_wiki               = true,
    is_template            = false,
    allow_merge_commit     = false,
    allow_squash_merge     = true,
    allow_rebase_merge     = false,
    allow_auto_merge       = true,
    delete_branch_on_merge = true,
    has_downloads          = false,
    auto_init              = true,
    archive_on_destroy     = true,
    vulnerability_alerts   = true,
    environments           = {}
    pages = {
      branch = ""
      path   = ""
      cname  = ""
    }
  })

  # List containing all combinations of repos and teams that can access them
  # Looks like this
  # repositories_x_teams_pull = [
  #     {
  #         repository = "data-hackathon"
  #         team       = "Data"
  #     },
  #     {
  #         repository = "dockerfiles"
  #         team       = "Platform"
  #      },
  #  ]
  repositories_x_teams_pull = flatten([for k, v in local.repositories : [for team in v.teams_pull_allowed : { "repository" = k, "team" = team } if v.teams_pull_allowed != []]])
  repositories_x_teams_push = flatten([for k, v in local.repositories : [for team in v.teams_push_allowed : { "repository" = k, "team" = team } if v.teams_push_allowed != []]])

  repositories_x_plaintext_secrets = flatten([for k, v in local.repositories : [for secret_key, secret_value in v.plaintext_secrets : { "repository" = k, "key" = secret_key, "value" = secret_value } if v.plaintext_secrets != null]])
  repositories_x_encrypted_secrets = flatten([for k, v in local.repositories : [for secret_key, secret_value in v.encrypted_secrets : { "repository" = k, "key" = secret_key, "value" = secret_value } if v.encrypted_secrets != null]])

  environments = flatten([for k, v in local.repositories : [for env_name, env_attributes in v.environments : { "name" = env_name, "repository" = k, "reviewers" = env_attributes["reviewers"], "protected_branches" = env_attributes["protected_branches"], "custom_branch_policies" = env_attributes["custom_branch_policies"] }]])
}
