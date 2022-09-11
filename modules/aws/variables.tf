variable "aws_region" {
  type        = string
  default     = "eu-central-1"
  description = "AWS Region to be used"
}

variable "github_app_id" {
  type        = string
  description = "AppID of Github App"
  default     = "236244"
}

variable "github_app_private_key" {
  type        = string
  description = "(optional) describe your variable"
  default     = <<EOF
-----BEGIN RSA PRIVATE KEY-----
MIIEpAIBAAKCAQEAromnZUX2+mHkT3P4lexjaOPvxfFOl6/wVDMdKRjirHiRKSE7
XwdVVq73YhJO+d2HZshEg889FChCMpKP6NK14LJRydw5oURTxZXH9cWJulfX2gTm
Kj3TrYc/l5JhVtNTzMjArM/IGLxYgtbyrJquCjss1myI8Plg0bgoLdsFg+aeG6c8
aenkUItWTiEouZsyBcvi7zyHqq6hibypPZ6aFZ2S1/Q5e4MpqmljEVXchJFeBLGH
Mp3TH51LbYNGHYmNvmqWEvI8EuX1Y27SjI/uJAv1ljlYnhp3fdCVnG+OWqgTtu7T
hynXXTi4MeY2/9dukb3Q5aS+csouuH5IaQoAtQIDAQABAoIBADmR/B4iismh2n3+
ocNJ+qxRavhelO7hwKL1TSwOIk6DYlYvuPaqY5K5Ga5Gnbg7Qvs7GaZkiCAK+3LU
9xTz07wu9V1g/71a3UryEcfWhYxqhy9JqGXMiPLXBrnHNcY+5IhKu4sE6lqGXaei
oN8gEkIbrLl5iV360925Ib+mW9ZagrK3Lk3frH/Vkpv0KyhIvkaCFGcJ+lgyFqtA
OmdYBZL6fOs2/j4kYzfbCjBgkTBysDmErsL2cVGwmagdYOW/TnhyRvQe2EFMa13X
4x3EYfOGWUcn20BIGZt3SIjqutLKsNurkEwYneHb/gfClHfgdgvALWEdvYGIU2Iv
jbLh5kECgYEA3keYv0ygVio0RbhMiaT34SQYqPMJJavnZOD6RU20f63Fk/6VUPJT
32tRGu+N55dOt1tNFlc9fJFgFGLbl37fcpudrzeIS0tbIrX+rsR/1oPnAft2yZkR
LqcUraaLXJCt0pRZp33/SFBc9PTxZkmLkrQgWEg7zKo4MWjNZ9OgfRECgYEAyQP2
CJ5oHc41Bithc5PgEsbEF2E/n5kX2cUioHszhx69MnNWJrszOrTIakrvz98QBzAO
C9gnGY2cx7aet5hNeJypvJAM46sHgU3pxl8n4yP70yZn0P4mzyx8sM62kXt3oq2A
oCfmDMzpBxAvLzXIMcrmuj4iptQwle6JGX5iGWUCgYEAq1cZQWz5szG5NX0JUpjd
kqjWcXVWObm3FqXthXqOhlUXFiuKQelqCbCZxl+eTUTvIpu4Yl5BQUJ2g4BosPDV
oWyfMi9mWlPuHmWXunQx7tOiQH7sZB4fhoy4fdsBVgsYUliUe22+WKnJ3fDqG+TZ
N+6teB/GKM+VnVCh9UTGU2ECgYBx4EuWUF79W59QUm0Ps9tB59aYxB/uAyWu2e4m
6gSj7HcUSKCqqmx4Oog7Jx66LU0ANWoPrbFg2YfS4BMEQUTKKj5CM30J0Q8cYo4o
Min/lJgJ43z2ubQ0s6gj5ccpnb+FqjLvCAtcfw0YUkPYw+gYxTB2m9K3nge0OID0
r1NVvQKBgQCteb2cL7XnEN1S9/kMyBBoOJ/omN3tBYZEuPOzvV0t6+Y4iejrgZ0H
OHeLqgYuB13PTxIgw5kT2yXtwUI4Ifsq0ZjTO+7egXpB02TCvLIVcDOmza34G9Ye
3Em06bBuemk4R0dhHplcMi2ko4woqEqG+76U6p+s3R6TkolKJQ8Fjw==
-----END RSA PRIVATE KEY-----
EOF
}

variable "okta_app_id" {
  type        = string
  description = "AppID of Okta App"
  default     = "0oa26b10p6roSGJ2c697"
}

variable "okta_app_private_key" {
  type        = string
  description = "Private Key of Okta App"
  sensitive   = true
  default     = <<EOF
{
    "d": "FMk_uGfDNeC1yLWPP3XWeRHnONHWmQZ6Mgo0lO2oOklZHqjZ5LcIHPuDj6iRZb6Yjgx0bpY0tjd1YM1kcf4GSgiWTjWETa4KVT5cGWu5KB05xzOWN-2boPzDByt85STWhbZCHYKvYJ1AUtJFhDP88CFDnway-YOY199GxiAul-QyCQ7_MMfT0saz7Jcntui3tmm7DmAw-ZkbnaOSdqQhHlpBln8Rd7qKsk9GTvRg1h7Z90HQz7mhniueGikxeVT6MOsBl20BED00HeCeymi2ZHtRvKr620-enNr9UbKZksxTppRO33Q5_Hn-hqer0AgIhU5PXHvzrbUvkPjQKAN6yQ",
    "p": "65ExpAh7hb0p2VSZ6tXzYYJwkV5nMPp5ESuVbBKLh6qagIrbP2uFaLNFX5HbOGcex2Z8JOPYZMTzysN3HMuPAFhg-U0CICD6cbFQ-J3lHdvfGIpQGUjDHgtGjmr-myuQafCeBmv-WXr7p3SXMR4DF3Je3xo3g77l1S5zM1x5ays",
    "q": "zQ8IwanYORS3TKS9nT32YeRBHA_SacaUwp7gSI_aPRs9oy0bKYZkAjFNc4M8iiK4GiJiDZOdTfYqycA9IJBxGWMndsEAGl7wu_Rb0WftMi4EfCgqAnt27Dm_g8a2tV8eoU5QRGMkgU3_myXIPl49i9uYUbv7YEQssOHQ9KgE3Bk",
    "dp": "1c57ytE0I-fUQwCpjt7PvxIgT6Dqcib0maQARA30_JbZEpB1fPN_K8-CyMJewau-4ObhCK6Qaq3kRIXy53zOd1a_9aZypmyoQ2bYAj91hAtbSy_GkZxcFDnRuVPdcUMyGSWemF-OhPK91Hha_eaqka5p838dIgOzITG-t8BYJ-8",
    "dq": "xEXUotG4FYK_pAu3Nm-dibtZmsuGIhqiPtqlYK7YPE77o1lEO23YAcVBFgSSiMGMp-8rHUWidoHeGLf5ilbW-m7O0jsPpy4ijDTrQbeQ8MvdHR2wgCm-_YKUzkQAk__UqJ71809WHLIUq2LxlMjNbjWlSO5-QHlgsXmjcNn1tNk",
    "qi": "jDWl_z26uS3WPGz5KjmkFcDkhFyGpNeJT6piRhw0VAk81STjb3a4ynY06PhhR9hgJWsmyK84HRa0PJLxMJedh7muvTY83quvuukABeDq8Foicx0bSbtDYS1oWoidkTuj04tQ3lEofek25ddyQmwUgfh9f3zBhNfcFuUaCTGyQIc",
    "kty": "RSA",
    "e": "AQAB",
    "kid": "IR-bBkEwfERYrcxqXhdUeucTmym3KoT6fFnENeNFNaA",
    "n": "vLEaUQG0xxEh96TL7aujshLEuDbe5MmYXsMVuURIaAXvp0d8_0U6hsS2llFGc4_1Yo9hP8vrqUWlVtmWoMExhXKQYkmYv7TThq6dZaNviDs2rQ4uVBGAVNVBDE4Vi9xQ3gEX1pyV07u8--zvTDPh3RRc1-OPviLwt0JQgeL78UiVnl4dI3Yb_k-qP5cM5Mj3sNsKNtQLDAS0PZp_nLowcezGXNZM0YCLGkIa6e1ue0o3VTIYxxUDINx1MiPRXkkqaZxZO-6jAew4INocxMDglBmX7Gzvpb-YfzLc1ZBXBvdBY6FFv2nTIg4bY9xbtMT-DrewTm92F9jJnpiyRKBrMw"
}
EOF
}
