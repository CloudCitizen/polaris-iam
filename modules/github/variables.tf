variable "repositories" {
  type = map(object({
    type                   = string
    description            = string
    visibility             = optional(string)
    gitignore_template     = optional(string)
    codeowners             = string
    teams_pull_allowed     = list(string)
    teams_push_allowed     = list(string)
    has_issues             = optional(bool)
    has_projects           = optional(bool)
    has_wiki               = optional(bool)
    is_template            = optional(bool)
    allow_merge_commit     = optional(bool)
    allow_squash_merge     = optional(bool)
    allow_rebase_merge     = optional(bool)
    allow_auto_merge       = optional(bool)
    delete_branch_on_merge = optional(bool)
    has_downloads          = optional(bool)
    auto_init              = optional(bool)
    archive_on_destroy     = optional(bool)
    vulnerability_alerts   = optional(bool)
    plaintext_secrets      = optional(map(string))
    encrypted_secrets      = optional(map(string))
    pages = optional(object({
      branch = string
      path   = string
      cname  = string
    }))
    environments = optional(map(object({
      reviewers              = list(string)
      protected_branches     = bool
      custom_branch_policies = bool
    })))
  }))
  description = "A map of maps containing all repositories and their configuration pertaining to this Github organization"
}
