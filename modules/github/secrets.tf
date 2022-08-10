# Organizational secrets

# Encrypted via:
# gh secret set secretname --org CloudCitizen --no-store

resource "github_actions_secret" "repo_plaintext_secret" {
  for_each = { for secret in local.repositories_x_plaintext_secrets : "${secret.repository}-${secret.key}" => secret }

  repository      = each.value.repository
  secret_name     = each.value.key
  plaintext_value = each.value.value
}

resource "github_actions_secret" "repo_encrypted_secret" {
  for_each = { for secret in local.repositories_x_encrypted_secrets : "${secret.repository}-${secret.key}" => secret }

  repository      = each.value.repository
  secret_name     = each.value.key
  encrypted_value = each.value.value
}
