# -----------------------------------------------------------------------------
# 1. VPC Module Invocation
# -----------------------------------------------------------------------------
module "vpc" {
  source = "../../modules/vpc"

  project_name = local.config.project.name
  environment  = local.config.project.env
  vpc_cidr     = local.config.aws.vpc_cidr
  region       = local.config.aws.region
}

# -----------------------------------------------------------------------------
# 2. S3 Module Invocation (for ClearML artifacts, datasets, logs)
# -----------------------------------------------------------------------------
module "s3_storage" {
  source = "../../modules/s3"

  project_name    = local.config.project.name
  environment     = local.config.project.env
  region          = local.config.aws.region
  bucket_names    = local.config.s3.bucket_types
  kms_key_alias   = local.config.kms.alias
}

# -----------------------------------------------------------------------------
# 3. EKS Cluster Module Invocation
# -----------------------------------------------------------------------------
module "eks_cluster" {
  source = "../../modules/eks"

  cluster_name    = "${local.config.project.name}-${local.config.project.env}-eks"
  vpc_id          = module.vpc.vpc_id
  private_subnets = module.vpc.private_subnets
  public_subnets  = module.vpc.public_subnets
  region          = local.config.aws.region
}

# -----------------------------------------------------------------------------
# 4. EKS Node Group Module Invocation
# -----------------------------------------------------------------------------
module "nodegroups" {
  source = "../../modules/nodegroups"

  cluster_name          = module.eks_cluster.cluster_name
  cluster_version       = local.config.aws.eks_version
  subnet_ids            = module.vpc.private_subnets
  nodegroup_definitions = local.config.nodegroups
}

# -----------------------------------------------------------------------------
# 5. IRSA Role for S3 Access (for ClearML Pods)
# -----------------------------------------------------------------------------
module "irsa_s3" {
  source = "../../modules/irsa"

  cluster_name    = module.eks_cluster.cluster_name
  namespace       = local.config.ansible.namespace
  service_account = "clearml-sa"
  policy_document = data.aws_iam_policy_document.s3_access.json
}

# Data document to grant S3 access to the IRSA role
data "aws_iam_policy_document" "s3_access" {
  statement {
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject",
      "s3:ListBucket"
    ]
    resources = concat(
      [for bucket_arn in module.s3_storage.bucket_arns : "${bucket_arn}"],
      [for bucket_arn in module.s3_storage.bucket_arns : "${bucket_arn}/*"],
    )
  }
}

# -----------------------------------------------------------------------------
# 6. ACM Certificate (Optional)
# -----------------------------------------------------------------------------
module "acm_cert" {
  source  = "../../modules/acm"
  count   = local.config.aws.dns_tls.enable ? 1 : 0

  domain_name = local.config.aws.dns_tls.domain_name
  hostname    = local.config.aws.dns_tls.hostname
  zone_id     = local.config.aws.dns_tls.route53_zone_id
  region      = local.config.aws.region
}

