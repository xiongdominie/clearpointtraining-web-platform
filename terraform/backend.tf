terraform {
  backend "s3" {
    bucket = "dominic-project1-terraform-state-2026"
    key    = "project1/terraform.tfstate"
    region = "us-east-1"
    use_lockfile = true
  }
}