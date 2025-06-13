terraform {
  backend "s3" {
    bucket       = "m8rmclaren-terraform-state-infra"
    key          = "prod/terraform_k8s.tfstate"
    region       = "us-west-1"
    encrypt      = true
    use_lockfile = true
  }
}

