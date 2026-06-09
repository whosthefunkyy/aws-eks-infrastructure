module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"
  name = var.vpc_name
  cidr = var.vpc_cidr

  azs = [
    "us-east-1a",
    "us-east-1b"
  ]

  public_subnets = [
    "10.0.1.0/24",
    "10.0.2.0/24"
  ]
  private_subnets = [
    "10.0.11.0/24",
    "10.0.12.0/24"
  ]
  enable_nat_gateway = true
  single_nat_gateway = true

  tags = {
    Project = "terraform-eks"
  }
  public_subnet_tags = {
    "kubernetes.io/role/elb"                    = "1"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb"           = "1"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }
}
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.31.0" 

  cluster_name    = var.cluster_name    
  cluster_version = var.cluster_version

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets
 
  cluster_endpoint_public_access  = true
  cluster_endpoint_private_access = true

  enable_cluster_creator_admin_permissions = true

  eks_managed_node_groups = {
    main = {
      instance_types = ["t3.medium"]

      min_size     = 1
      max_size     = 2
      desired_size = 2
    }
  }

  # Исправленное имя аргумента для аддонов:
  cluster_addons = {
    coredns = {
      most_recent = true
    }

    kube-proxy = {
      most_recent = true
    }

    vpc-cni = {
      most_recent = true
    }
  }
}