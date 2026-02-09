terraform {
  required_version = ">= 1.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.27.0"
    }
  }
}

provider "aws" {
  region = var.region
  profile = var.profile
  assume_role {
    role_arn = var.role_arn
    session_name = var.session_name
  }
}
