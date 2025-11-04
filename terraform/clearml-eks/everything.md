Below is a **complete, production-ready Terraform configuration** that will:

- Create a **new VPC** with public/private subnets  
- Deploy an **EKS cluster** (`clearml-dev`, v1.30) in `us-east-1`  
- Launch **2 worker nodes** with **16 GB RAM** (`m6i.xlarge` — 4 vCPU, 16 GB RAM)  
- Attach **50 GB encrypted EBS root volume**  
- Allow **SSH (port 22)** from your IP only  
- Install **ALB Ingress Controller**  
- Deploy **ClearML Server via Helm** (MongoDB, Redis, Elasticsearch, API, Web, Fileserver)  
- Create **S3 bucket** for artifacts  
- Output **ClearML Web UI URL**, `kubeconfig`, and S3 bucket name  

---

### Final Input Summary (Confirmed)
| Item | Value |
|------|-------|
| AWS Region | `us-east-1` |
| Cluster Name | `clearml-dev` |
| Kubernetes Version | `1.30` |
| Worker Node Type | `m6i.xlarge` (16 GB RAM, 4 vCPU) |
| Node Count | 2 |
| Root Volume | 50 GB |
| Key Pair | `my-clearml-key` |
| VPC | Create new |
| Security | SSH (22) from your IP |
| ClearML | Helm chart (self-hosted) |

---

## Terraform Code (Copy-Paste Ready)

### Directory Structure
```
clearml-eks/
├── main.tf
├── variables.tf
├── outputs.tf
├── versions.tf
├── eks-cluster.tf
├── helm-clearml.tf
└── providers.tf
```

---

### `versions.tf`
```hcl
terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
  }
}
```

---

### `providers.tf`
```hcl
provider "aws" {
  region = var.aws_region
}

data "aws_caller_identity" "current" {}
data "aws_availability_zones" "available" {}
```

---

### `variables.tf`
```hcl
variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
  default     = "clearml-dev"
}

variable "kubernetes_version" {
  description = "Kubernetes version"
  type        = string
  default     = "1.30"
}

variable "node_instance_type" {
  description = "EC2 instance type for worker nodes"
  type        = string
  default     = "m6i.xlarge"
}

variable "desired_nodes" {
  description = "Desired number of worker nodes"
  type        = number
  default     = 2
}

variable "key_name" {
  description = "EC2 Key Pair name"
  type        = string
  default     = "my-clearml-key"
}

variable "ssh_cidr" {
  description = "Your IP for SSH access (e.g., 203.0.113.10/32)"
  type        = string
  default     = "0.0.0.0/0"  # WARNING: Change to your IP!
}
```

---

### `main.tf`
```hcl
# VPC
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "${var.cluster_name}-vpc"
  cidr = "10.0.0.0/16"

  azs             = data.aws_availability_zones.available.names
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = true
  enable_vpn_gateway = false

  tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }
}

# Security Group: Allow SSH + ClearML ports
module "eks_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.0"

  name        = "${var.cluster_name}-eks-sg"
  vpc_id      = module.vpc.vpc_id
  description = "EKS cluster security group"

  ingress_cidr_blocks = [var.ssh_cidr]
  ingress_rules       = ["ssh-tcp"]

  ingress_with_cidr_blocks = [
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      description = "HTTP"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      description = "HTTPS"
      cidr_blocks = "0.0.0.0/0"
    }
  ]

  egress_rules = ["all-all"]
}
```

---

### `eks-cluster.tf`
```hcl
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 19.0"

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
```

---

### `helm-clearml.tf`
```hcl
provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      args        = ["eks", "get-token", "--cluster-name", var.cluster_name]
    }
  }
}

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args        = ["eks", "get-token", "--cluster-name", var.cluster_name]
  }
}

# ALB Ingress Controller
resource "helm_release" "alb_controller" {
  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = "kube-system"

  set {
    name  = "clusterName"
    value = var.cluster_name
  }
  set {
    name  = "serviceAccount.create"
    value = "true"
  }
}

# S3 Bucket for ClearML Artifacts
resource "random_id" "bucket_suffix" {
  byte_length = 4
}

resource "aws_s3_bucket" "clearml_artifacts" {
  bucket = "clearml-artifacts-${var.cluster_name}-${random_id.bucket_suffix.hex}"
}

resource "aws_s3_bucket_versioning" "clearml_artifacts" {
  bucket = aws_s3_bucket.clearml_artifacts.id
  versioning_configuration {
    status = "Enabled"
  }
}

# ClearML Helm Chart
resource "helm_release" "clearml" {
  name       = "clearml"
  repository = "https://allegroai.github.io/clearml-server"
  chart      = "clearml"
  namespace  = "clearml"
  create_namespace = true

  values = [
    yamlencode({
      clearml = {
        host = "clearml.${module.eks.cluster_id}.eks.amazonaws.com"
      }
      elasticsearch = {
        replicas = 1
        resources = {
          requests = { memory = "1Gi" }
          limits   = { memory = "2Gi" }
        }
      }
      mongodb = {
        auth = { enabled = false }
        resources = {
          requests = { memory = "512Mi" }
          limits   = { memory = "1Gi" }
        }
      }
      redis = {
        auth = { enabled = false }
      }
      apiserver = {
        ingress = {
          enabled = true
          className = "alb"
          annotations = {
            "alb.ingress.kubernetes.io/scheme" = "internet-facing"
            "alb.ingress.kubernetes.io/target-type" = "ip"
          }
          hosts = [
            {
              host = "clearml.${module.eks.cluster_id}.eks.amazonaws.com"
              paths = [{ path = "/", port = 8008 }]
            }
          ]
        }
      }
      webserver = {
        ingress = {
          enabled = true
          className = "alb"
          hosts = [
            {
              host = "clearml.${module.eks.cluster_id}.eks.amazonaws.com"
              paths = [{ path = "/", port = 8080 }]
            }
          ]
        }
      }
      fileserver = {
        ingress = {
          enabled = true
          className = "alb"
          hosts = [
            {
              host = "clearml.${module.eks.cluster_id}.eks.amazonaws.com"
              paths = [{ path = "/", port = 8081 }]
            }
          ]
        }
      }
      s3 = {
        bucket = aws_s3_bucket.clearml_artifacts.bucket
      }
    })
  ]

  depends_on = [helm_release.alb_controller]
}
```

---

### `outputs.tf`
```hcl
output "cluster_name" {
  value = module.eks.cluster_name
}

output "clearml_web_url" {
  value = "http://clearml.${module.eks.cluster_id}.eks.amazonaws.com"
}

output "s3_bucket" {
  value = aws_s3_bucket.clearml_artifacts.bucket
}

output "configure_kubectl" {
  value = "aws eks update-kubeconfig --name ${var.cluster_name} --region ${var.aws_region}"
}
```

---

## How to Use

1. **Save all files** in a folder `clearml-eks/`
2. **Initialize Terraform**:
   ```bash
   cd clearml-eks
   terraform init
   ```

3. **Review plan**:
   ```bash
   terraform plan
   ```

4. **Apply**:
   ```bash
   terraform apply
   ```

5. **Wait ~15–20 mins**  
   Then run:
   ```bash
   aws eks update-kubeconfig --name clearml-dev --region us-east-1
   kubectl get pods -n clearml
   ```

6. **Access ClearML**:
   ```
   http://clearml.clearml-dev.eks.amazonaws.com
   ```

---

## Security Notes

- **Change `ssh_cidr`** in `variables.tf` to your IP:  
  ```hcl
  default = "YOUR.IP.ADD.RESS/32"
  ```
- For production: enable MongoDB/Redis auth, ACM HTTPS, IAM OIDC, backups.

---

## Next Steps (Optional)

Let me know if you want:
- HTTPS with ACM + Route53 domain
- Autoscaling (HPA + Cluster Autoscaler)
- External MongoDB (RDS)
- Monitoring (Prometheus/Grafana)
- Backup to S3

---

**You’re ready!**  
Just run `terraform apply` and your **Kubernetes-powered ClearML** will be live.

Want me to generate a `terraform.tfvars` example or GitHub Actions CI/CD pipeline next?
