terraform {
    required_version = ">=0.12"
    #required_providers {
    #aws = {
     # source  = "hashicorp/aws"
     # version = "~> 3.0"
    #}
  #}
    #backend "s3"{
       #bucket = "my-eks-tf"
       #key = "my-eks.tfstate"
       #region = "us-west-2"
   # }
}
provider "aws" {
    region = "us-west-2"
    access_key = var.aws_accesskey
    secret_key = var.aws_secret

}