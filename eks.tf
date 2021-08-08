locals {
  cluster_name = "asantra-eks-${random_string.suffix.result}"
}

resource "random_string" "suffix" {
  length  = 8
  special = false
}

data "aws_eks_cluster" "eks_cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}
 

# Provision EKS cluster with managed node group

module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  cluster_name    = local.cluster_name
  cluster_version = "1.20"
  subnets         = module.vpc.private_subnets

  tags = {
    Environment = "test"
  }

  vpc_id = module.vpc.vpc_id

  node_groups_defaults = {
    ami_type  = "AL2_x86_64"
    disk_size = 50
  }

  # Try to emulate the actual infratructure where the node-group-2 has taints 
  # to deploy for test environment.
  node_groups = {
    node_group_1 = {
      desired_capacity = 3
      max_capacity     = 6
      min_capacity     = 2

      instance_types = ["t2.micro"]
      k8s_labels = {
        Environment = "Dev"
      }
      additional_tags = {
        ExtraTag = "example"
      }
    }
  }
}