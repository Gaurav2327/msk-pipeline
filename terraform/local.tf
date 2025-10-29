locals {
  region = "us-east-1"
  default_tags = {
    resource = "msk"
    stack    = "github-resources"
    repo_url = "https://github.com/Gaurav2327/terraform-aws-msk-pipeline.git"
  }
}