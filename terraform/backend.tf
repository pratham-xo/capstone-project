terraform {
  backend "s3" {
    bucket         = "capstone-terraform-state-hp4vjc"
    key            = "capstone/terraform.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "terraform_locks"
    encrypt = true
  }
}