resource "github_organization_webhook" "datadog" {

  configuration {
    url          = "https://app.datadoghq.eu/intake/webhook/github?api_key=92c52db3939defb5fa4a514801e994ac"
    content_type = "form"
    insecure_ssl = false
  }

  active = false

  events = ["issues"]
}
