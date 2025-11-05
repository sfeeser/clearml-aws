module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name                    = var.cluster_name
  cluster_version                 = var.kubernetes_version
  vpc_id                          = module.vpc.vpc_id
  subnet_ids                      = module.vpc.private_subnets
  cluster_endpoint_public_access  = true
  cluster_endpoint_private_access = true

  cluster_addons = {
    coredns = {}
    kube-proxy = {}
    vpc-cni = {}
  }

  eks_managed_node_groups = {
    clearml = {
      desired_size = var.desired_nodes
      min_size     = 1
      max_size     = 5

      instance_types = [var.node_instance_type]
      key_name       = var.key_name

      block_device_mappings = {
        xvda = {
          device_name = "/dev/xvda"
          ebs = {
            volume_size = 50
            volume_type = "gp3"
            encrypted   = true
          }
        }
      }

      labels = {
        role = "clearml-worker"
      }
    }
  }

  node_security_group_id = module.eks_sg.security_group_id

  tags = {
    Environment = "dev"
    Project     = "ClearML"
  }
}

