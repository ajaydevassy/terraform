terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}
variable "secret_key" {
  description = "enter secret"
}
variable "access_key" {
  description = "enter secret"
  
}
provider "aws" {
    region = "us-west-2"
    access_key = var.access_key
    secret_key = var.secret_key
  
}

resource "aws_instance" "my-ec2" {

    ami = "ami-0c2d06d50ce30b442"
    instance_type = "t2.micro"
    tags = {
        Name = "my-test"
    }

}