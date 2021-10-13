#EKS cluster id
data "aws_eks_cluster" "cluster" {
    name=module.eks.cluster_id
  
}
data "aws_eks_cluster_auth" "cluster" {
    name=module.eks.cluster_id
  
}

#kubernetes provider
provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.cluster.token
  #load_config_file = false
  #version = "~> 1.20"
}
data "aws_availability_zones" "available" {
  
}
locals {
  cluster_name = "my-eks-cluster"
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  version = "3"

  name = "my-vpc"
  cidr = "10.0.0.0/16"

  azs             = data.aws_availability_zones.available.names
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_nat_gateway = true
  enable_vpn_gateway = true
  enable_dns_hostnames = true

  tags = {
    Terraform = "true"
    Environment = "Test"

  }
  public_subnet_tags = {
      "k8's/cluster/${local.cluster_name}"= "shared"
      "k8's/role/elb" = "1"
  }
  private_subnet_tags={
      "k8's/cluster/${local.cluster_name}"= "shared"
      "k8's/role/internal-elb" = "1"
  }
}
module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  #version = "12.2.0"

  cluster_version = "1.20"
  cluster_name    = "${local.cluster_name}"
  vpc_id          = module.vpc.vpc_id
  subnets         = module.vpc.private_subnets

 
  worker_groups = [
    {
      instance_type = "m4.large"
      asg_max_size  = 3
    }
  ]
  write_kubeconfig = true
  #config_output_path = "./"

}
output "kubeconfig"{
   value = module.eks.kubeconfig_filename
}
#get bucket
#data "aws_s3_bucket" "getbucket" {
  #bucket = "my-eks-tf"
#}

#s3 bucketobject
#resource "aws_s3_bucket_object" "object"{
  #bucket = data.aws_s3_bucket.getbucket.id
  #key = module.eks.kubeconfig.file_name
  #source = "./${module.eks.kubeconfig.file_name}"
#}