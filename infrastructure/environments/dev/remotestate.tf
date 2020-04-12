terraform {
  backend "s3" {
    encrypt = true
    bucket = "lsccrafflerremotestate"
    region = "eu-west-2"
    key = "lsccraffler.tfstate"
  }
}
