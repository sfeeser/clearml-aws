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

