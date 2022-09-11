inputs = {
  global_tags = {
    Project   = "polaris"
    Owner     = "platform"
    CreatedBy = "terraform"
    ManagedBy = "repo/polaris-iam"
  }
}

remote_state {
  backend = "s3"

  config = {
    region         = "eu-central-1"
    encrypt        = true
    dynamodb_table = "tf-polaris-iam"
    bucket         = "tf-polaris-iam"
    key            = "${get_aws_account_id()}/polaris-iam/${path_relative_to_include()}/terraform.tfstate"
  }
}
