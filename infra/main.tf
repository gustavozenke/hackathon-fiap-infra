terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.66.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

# terraform.tfstate
terraform {
  backend "s3" {
    bucket = "tech-challenge-terraform-tfstate"
    key    = "terraform.tfstate"
    region = "us-east-1"
  }
}