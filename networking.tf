module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "main"
  cidr = "10.0.0.0/16"

  azs             = ["eu-west-2a", "eu-west-2b"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]

  enable_nat_gateway   = false
  enable_vpn_gateway   = false
  enable_dns_hostnames = true

  # Add the public subnet tags in order to create the inetetnet facing ALB created automatically 
  # by AWS Load Balancer Controller
  public_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                      = "1"
    "SubnetType" = "private"
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"             = "1"
    "SubnetType" = "public"
  }

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}

// The following outputs will be requred
// public_route_table_ids
// public_subnets
// private_subnets
// private_route_table_ids
// 