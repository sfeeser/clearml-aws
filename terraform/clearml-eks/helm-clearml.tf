# === S3 BUCKET (unchanged) ===
resource "random_pet" "bucket_suffix" {
  length = 2
}

resource "aws_s3_bucket" "clearml_artifacts" {
  bucket        = "clearml-artifacts-${var.cluster_name}-${random_pet.bucket_suffix.id}"
  force_destroy = true
}

resource "aws_s3_bucket_versioning" "clearml_artifacts" {
  bucket = aws_s3_bucket.clearml_artifacts.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "clearml_artifacts" {
  bucket = aws_s3_bucket.clearml_artifacts.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# === ALB Controller via local-exec ===
resource "null_resource" "install_alb_controller" {
  triggers = {
    cluster_endpoint = module.eks.cluster_endpoint
    cluster_name     = var.cluster_name
  }

  provisioner "local-exec" {
    command = <<EOT
      # Wait for cluster
      until aws eks describe-cluster --name ${var.cluster_name} --region ${var.aws_region} --query 'cluster.status' --output text | grep -q "ACTIVE"; do
        echo "Waiting for EKS cluster..."
        sleep 10
      done

      # Update kubeconfig
      aws eks update-kubeconfig --name ${var.cluster_name} --region ${var.aws_region}

      # Install ALB Controller
      helm upgrade --install aws-load-balancer-controller \
        aws-load-balancer-webhook-service \
        --repo https://aws.github.io/eks-charts \
        --namespace kube-system \
        --set clusterName=${var.cluster_name} \
        --set serviceAccount.create=true \
        --wait --timeout 10m
    EOT
  }

  depends_on = [
    module.eks.cluster_id,
    module.eks.eks_managed_node_groups
  ]
}

# === ClearML via local-exec ===
resource "null_resource" "install_clearml" {
  triggers = {
    bucket_name      = aws_s3_bucket.clearml_artifacts.bucket
    cluster_endpoint = module.eks.cluster_endpoint
  }

  provisioner "local-exec" {
    command = <<EOT
      # Ensure kubeconfig
      aws eks update-kubeconfig --name ${var.cluster_name} --region ${var.aws_region}

      # Install ClearML
      helm upgrade --install clearml clearml \
        --repo https://allegroai.github.io/clearml-server \
        --namespace clearml \
        --create-namespace \
        --set clearml.host="clearml.${replace(module.eks.cluster_endpoint, "https://", "")}" \
        --set s3.bucket=${aws_s3_bucket.clearml_artifacts.bucket} \
        --set mongodb.auth.enabled=false \
        --set redis.auth.enabled=false \
        --set elasticsearch.replicas=1 \
        --set apiserver.ingress.enabled=true \
        --set apiserver.ingress.className=alb \
        --set apiserver.ingress.annotations."alb\\.ingress\\.kubernetes\\.io/scheme"=internet-facing \
        --set apiserver.ingress.annotations."alb\\.ingress\\.kubernetes\\.io/target-type"=ip \
        --set apiserver.ingress.hosts[0].host="clearml.${replace(module.eks.cluster_endpoint, "https://", "")}" \
        --set apiserver.ingress.hosts[0].paths[0].path="/" \
        --set apiserver.ingress.hosts[0].paths[0].port=8008 \
        --set webserver.ingress.enabled=true \
        --set webserver.ingress.className=alb \
        --set webserver.ingress.hosts[0].host="clearml.${replace(module.eks.cluster_endpoint, "https://", "")}" \
        --set webserver.ingress.hosts[0].paths[0].path="/" \
        --set webserver.ingress.hosts[0].paths[0].port=8080 \
        --set fileserver.ingress.enabled=true \
        --set fileserver.ingress.className=alb \
        --set fileserver.ingress.hosts[0].host="clearml.${replace(module.eks.cluster_endpoint, "https://", "")}" \
        --set fileserver.ingress.hosts[0].paths[0].path="/" \
        --set fileserver.ingress.hosts[0].paths[0].port=8081 \
        --wait --timeout 15m
    EOT
  }

  depends_on = [
    null_resource.install_alb_controller,
    module.eks.cluster_id
  ]
}
