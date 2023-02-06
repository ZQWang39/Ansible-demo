
#Provision AWS VPC resources for EKS cluster(worker nodes)

provider "aws" {
  region = "ap-southeast-2"
}

variable vpc_cidr_block{}
variable private_subnet_cidr_blocks{}
variable public_subnet_cidr_blocks{}
#Filter the azs
data "aws_availability_zones" "azs"{}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.19.0"

  name = "myapp-vpc"
  cidr = var.vpc_cidr_block
  #["eu-west-1a", "eu-west-1b", "eu-west-1c"]
  azs = data.aws_availability_zones.azs.names
  #["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  private_subnets = var.private_subnet_cidr_blocks
  #["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
  public_subnets  = var.public_subnet_cidr_blocks 

  enable_nat_gateway = true
  single_nat_gateway = true
  enable_dns_hostnames = true
 
  #For human consumption to have more info, 
  #also label for referecing components for other components(Cloud Controler Manager-eks control plane)
  tags = {
    "kubernetes.io/cluster/myapp-eks-cluster" = "shared"
  }

  public_subnet_tags = {
    "kubernetes.io/cluster/myapp-eks-cluster" = "shared"
    "kubernetes.io/role/elb" = 1 
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/myapp-eks-cluster" = "shared"
    "kubernetes.io/role/internal-elb" = 1 
  }
}