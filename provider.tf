terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }
  backend "s3" {
    bucket         = "terraform-remote-state-mk-0808"
    key            = "/remote/terraform.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "terraform-remote-state"
  }
}

provider "aws" {
  profile = "default"
  region  = "ap-south-1"
}
