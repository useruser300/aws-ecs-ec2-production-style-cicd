terraform {
  backend "s3" {
    bucket = "backend-bucket-terraform-asd"
    key    = "terraform.tfstate"
    region = "eu-central-1"
  }
}
