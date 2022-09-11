data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "app_private_key_policy" {
  version = "2012-10-17"
  statement {
    sid    = "AllowKeyAdministration"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    actions = [
      "kms:Create*",
      "kms:Describe*",
      "kms:Enable*",
      "kms:List*",
      "kms:Put*",
      "kms:Update*",
      "kms:Revoke*",
      "kms:Get*",
      "kms:Delete*",
      "kms:ScheduleKeyDeletion",
      "kms:CancelKeyDeletion",
      "kms:GenerateDataKey",
      "kms:Decrypt",
      "kms:ReEncryptFrom",
      "kms:ReEncryptTo",
      "kms:TagResource",
    ]
    resources = ["*"]
  }
  statement {
    sid    = "AllowKeyReadonly"
    effect = "Allow"
    principals {
      type = "AWS"
      identifiers = [
        module.github_token.lambda_role_arn,
        # "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/github_readonly"
      ]
    }
    actions = [
      "kms:Describe*",
      "kms:List*",
      "kms:Get*",
      "kms:Decrypt"
    ]
    resources = ["*"]
  }
}

resource "aws_kms_key" "github_app_private_key" {
  description         = "KMS key for Github App Private Key"
  policy              = data.aws_iam_policy_document.app_private_key_policy.json
  enable_key_rotation = true
}

resource "aws_kms_key" "okta_app_private_key" {
  description         = "KMS key for Okta App Private Key"
  policy              = data.aws_iam_policy_document.app_private_key_policy.json
  enable_key_rotation = true
}

data "aws_iam_policy_document" "token_secret_policy" {
  version = "2012-10-17"
  statement {
    sid    = "AllowSecretAccess"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    actions   = ["secretsmanager:GetSecretValue"]
    resources = ["*"]
    condition {
      test     = "StringLike"
      variable = "aws:PrincipalArn"
      values   = ["*"]
    }
  }
}

resource "aws_secretsmanager_secret" "github_app_private_key" {
  name       = "github_app_private_key"
  policy     = data.aws_iam_policy_document.token_secret_policy.json
  kms_key_id = aws_kms_key.github_app_private_key.arn
}

resource "aws_secretsmanager_secret_version" "github_app_private_key" {
  secret_id     = aws_secretsmanager_secret.github_app_private_key.id
  secret_string = var.github_app_private_key
}

resource "aws_secretsmanager_secret" "okta_app_private_key" {
  name       = "okta_app_private_key"
  policy     = data.aws_iam_policy_document.token_secret_policy.json
  kms_key_id = aws_kms_key.okta_app_private_key.arn
}

resource "aws_secretsmanager_secret_version" "okta_app_private_key" {
  secret_id     = aws_secretsmanager_secret.okta_app_private_key.id
  secret_string = var.okta_app_private_key
}

data "aws_iam_policy_document" "github_token_execution" {
  statement {
    actions = [
      "kms:Decrypt",
    ]
    resources = [aws_kms_key.github_app_private_key.arn]
  }

  statement {
    actions = [
      "secretsmanager:GetSecretValue",
    ]
    resources = [aws_secretsmanager_secret.github_app_private_key.arn]
  }
}

#tfsec:ignore:aws-vpc-no-public-egress-sgr Required for sending requests
resource "aws_security_group" "github_token" {
  name        = "github_token_sg"
  description = "Allow outbound HTTPS traffic"
  vpc_id      = local.shared_vpc_id

  egress {
    description = "Allow HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

data "aws_iam_policy_document" "github_assume_policy" {
  statement {
    sid = "TrustCloudCitizenRepos"

    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/token.actions.githubusercontent.com"]
    }

    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"

      values = [
        "repo:CloudCitizen/*:ref:refs/heads/*",
        "repo:CloudCitizen/*:pull_request",
        "repo:CloudCitizen/*:environment:*",
      ]
    }
  }
}

module "github_token" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "~> 3.1"

  function_name      = "github_token"
  description        = "Lambda function that performs an exchange of OIDC JTW from Github with Github Tokens"
  handler            = "main.lambda_handler"
  runtime            = "python3.9"
  timeout            = 15
  attach_policy_json = true
  policy_json        = data.aws_iam_policy_document.github_token_execution.json
  source_path        = "${path.module}/scripts/github_token"

  vpc_subnet_ids         = local.private_subnet_ids
  vpc_security_group_ids = [aws_security_group.github_token.id]
  attach_network_policy  = true

  environment_variables = {
    GITHUB_ORG                    = "CloudCitizen",
    GITHUB_APP_ID                 = "236244",
    OKTA_APP_ID                   = var.okta_app_id,
    GITHUB_PRIVATE_KEY_SECRET_ARN = aws_secretsmanager_secret.github_app_private_key.arn,
    OKTA_PRIVATE_KEY_SECRET_ARN   = aws_secretsmanager_secret.okta_app_private_key.arn
  }
}

data "aws_iam_policy_document" "github_token_invoke_lambda" {
  statement {
    sid = "GithubTokenInvokeLambda"
    actions = [
      "lambda:InvokeFunction"
    ]
    resources = [
      module.github_token.lambda_function_arn
    ]
  }
}

resource "aws_iam_role" "github_token_exchange" {
  name               = "github_token_exchange"
  assume_role_policy = data.aws_iam_policy_document.github_assume_policy.json
}

resource "aws_iam_role_policy" "github_token_exchange" {
  name   = "GithubTokenInvokeLambda"
  role   = aws_iam_role.github_token_exchange.name
  policy = data.aws_iam_policy_document.github_token_invoke_lambda.json
}
