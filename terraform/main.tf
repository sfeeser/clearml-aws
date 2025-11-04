# 1. Define the specific permissions for the ClearML Fileserver
module "clearml_fileserver_policy" {
  source          = "./modules/clearml-s3-policy"
  # Referencing the specific 'clearml' bucket from the S3 module's resource map
  s3_bucket_arn   = aws_s3_bucket.app_storage["clearml"].arn
}

# 2. Apply those permissions to the Kubernetes Service Account
module "clearml_fileserver_irsa" {
  source           = "./modules/irsa"
  cluster_name     = var.cluster_name
  service_account  = "clearml-fileserver"
  namespace        = "clearml"
  policy_document  = module.clearml_fileserver_policy.policy_json # Assuming the output name
  oidc_issuer      = var.eks_oidc_issuer
}
