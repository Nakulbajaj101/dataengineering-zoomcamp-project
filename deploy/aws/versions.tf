terraform {
    required_version = "1.3.9"
    required_providers {
      aws = {
        source = "hashicorp/aws"
        version = ">= 3.72.0"

      }
    }
    backend "s3" {
    bucket = "tf-state-mlops-zoomcamp-nbajaj"
    key = "de-zoomcamp-prod.tfstate"
    region = "us-east-1"
    encrypt = true
  }
}

provider "aws" {
  region = "us-east-2"
}