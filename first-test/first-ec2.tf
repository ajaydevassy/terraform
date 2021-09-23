terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}
provider "aws" {
    region = "us-west-2"
    access_key = "AKIA3ZC7ID2V5QZ67SN4"
    secret_key = "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"
  
}

resource "aws_instance" "my-ec2" {

    ami = "ami-0c2d06d50ce30b442"
    instance_type = "t2.micro"
    tags = {
        Name = "my-test"
    }

}