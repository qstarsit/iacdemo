# Basic terraform configuration

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.36.0"
    }
  }
}

provider "aws" {
  region = "eu-west-3"
}
