terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  backend "s3"{
	bucket = "kiru-infra-bucket"
	key    = "kiru/terraform.tfstate"
	region = "ap-south-1"
  }

}


# Provider Block
provider "aws" {
  region  = "ap-south-1"
}
