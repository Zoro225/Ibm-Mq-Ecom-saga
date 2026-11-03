
terraform {
  backend "s3" {
    bucket       = "order-saga-terraform-state-824225573600"
    key          = "order-saga/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}

