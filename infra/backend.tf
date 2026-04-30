terraform {
  backend "s3" {
    bucket       = "eks-tfstate-project-unique-001"
    region       = "eu-west-3"
    encrypt      = true
    use_lockfile = true
  }
}
