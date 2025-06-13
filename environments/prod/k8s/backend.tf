terraform {
  backend "s3" {
    bucket       = "m8rmclaren-terraform-state-infra"
    key          = "prod_k8s/terraform.tfstate"
    region       = "us-west-1"
    encrypt      = true
    use_lockfile = true
  }
}

