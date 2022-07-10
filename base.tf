terraform {
  required_version = ">= 1.2.0"

  cloud {
    organization = "pydataco"
    workspaces {
      name = "terraform"
    }
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }
}
