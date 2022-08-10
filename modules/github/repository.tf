locals {
  status_checks = {
    terraform = ["terraform_ready / ready"],
    docker    = ["build / Build Docker images and push to ECR"],
  }

  dependabot = {
    "terraform" = "terraform.yml"
  }
}

resource "github_repository" "repo" {
  for_each = local.repositories

  name                   = each.key
  description            = each.value.description
  visibility             = each.value.visibility
  has_downloads          = each.value.has_downloads
  has_issues             = each.value.has_issues
  has_projects           = each.value.has_projects
  has_wiki               = each.value.has_wiki
  is_template            = each.value.is_template
  allow_merge_commit     = each.value.allow_merge_commit
  allow_squash_merge     = each.value.allow_squash_merge
  allow_rebase_merge     = each.value.allow_rebase_merge
  allow_auto_merge       = each.value.allow_auto_merge
  delete_branch_on_merge = each.value.delete_branch_on_merge
  auto_init              = each.value.auto_init
  archive_on_destroy     = each.value.archive_on_destroy
  gitignore_template     = each.value.gitignore_template
  vulnerability_alerts   = each.value.vulnerability_alerts
  dynamic "pages" {
    for_each = (each.value.pages != null) ? [1] : []
    content {
      cname = each.value.pages.cname
      source {
        branch = each.value.pages.branch
        path   = each.value.pages.path
      }
    }
  }

  dynamic "template" {
    for_each = (each.value.type != "plain") ? [1] : []

    content {
      owner      = "CloudCitizen"
      repository = "template-${each.value.type}"
    }
  }
}

resource "github_team_repository" "teams_push_allowed" {
  for_each = { for repo in local.repositories_x_teams_push : "${repo.repository}-${repo.team}" => repo }

  team_id    = github_team.cloudcitizen_team[each.value.team].slug
  repository = each.value.repository
  permission = "push"
}

resource "github_repository_file" "codeowners" {
  for_each = { for k, v in local.repositories : k => v if v.codeowners != null }

  repository          = github_repository.repo[each.key].name
  branch              = "main"
  file                = ".github/CODEOWNERS"
  content             = each.value.codeowners
  commit_message      = "Updated codeowners"
  commit_author       = "Terraform User"
  commit_email        = "terraform@cloudcitizen.eu"
  overwrite_on_create = true
}

resource "github_branch_protection" "repo_protect_main" {
  for_each = local.repositories

  repository_id       = github_repository.repo[each.key].name
  pattern             = "main"
  allows_deletions    = false
  allows_force_pushes = false

  required_status_checks {
    strict   = true
    contexts = lookup(local.status_checks, each.value.type, [])
  }

  required_pull_request_reviews {
    dismiss_stale_reviews           = true
    required_approving_review_count = 1
    require_code_owner_reviews      = true
  }
}

resource "github_repository_environment" "environment" {
  for_each = { for environment in local.environments : "${environment.repository}-${environment.name}" => environment }

  environment = each.value.name
  repository  = each.value.repository

  reviewers {
    teams = [for reviewer in each.value.reviewers : github_team.cloudcitizen_team[reviewer].id] # no team slug allowed for reviewers
  }
  deployment_branch_policy {
    protected_branches     = each.value.protected_branches
    custom_branch_policies = each.value.custom_branch_policies
  }
  depends_on = [
    github_repository.repo
  ]
}

moved {
  from = github_repository.repo["wkl-exploration"]
  to   = github_repository.repo["wkl-model-exploration"]
}

moved {
  from = github_repository.repo["wkl-model-development"]
  to   = github_repository.repo["wkl-model-execution"]
}
