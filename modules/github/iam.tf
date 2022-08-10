locals {
  teams = toset(["Infrastructure"])
}

resource "github_team" "cloudcitizen_team" {
  for_each = local.teams

  name    = each.key
  privacy = "closed"
}
