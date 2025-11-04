# S3 Module: The Dedicated Storage Array

## Module Overview: Off-Cluster Storage

The `s3/` module provisions the highly durable, non-ephemeral storage required for **ClearML Enterprise**.  

In a "racker and stacker" context, this module creates and configures the equivalent of a dedicated, high-end **Network Attached Storage (NAS)** array or a **Storage Area Network (SAN)** volume.  

Crucially, this storage exists **outside the Kubernetes cluster**, making it independent and highly resilient.

The module provides **three distinct, highly secure storage volumes (buckets):**
- `artifacts`
- `datasets`
- `logs`


## Racker and Stacker Translation

| On-Premises Component | S3 (AWS) Component | Purpose |
|------------------------|--------------------|----------|
| Dedicated SAN/NAS | `aws_s3_bucket` | Provides resilient, object-based storage volumes. |
| Encrypted Disk Volume | KMS Encryption | Ensures all data is encrypted at rest using the provided KMS Key. |
| Drive Erasure Policy | `force_destroy = true` | Mandatory safety setting ensuring the volume is completely wiped on `terraform destroy`. |
| ACL Setup / Volume Permissions | Bucket Ownership Enforcement | Simplifies permissions for the application identity (IRSA), preventing object write failures. |


## Key Security and Reliability Features

The `main.tf` file enforces the following best practices for production-ready storage:

1. **Deterministic Naming:**  
   Ensures all bucket names are globally unique and tied directly to the project identity (`project-env-purpose-accountID`).

2. **Public Access Block:**  
   All four controls are enabled to block public access, ensuring zero internet exposure.

3. **Ownership Controls (Critical):**  
   The `BucketOwnerEnforced` setting is enabled — this is **critical** for cloud-native workloads like Kubernetes using IRSA.  
   It ensures the application's service account has consistent write permissions.

4. **Versioning:**  
   Enabled for all buckets, providing historical tracking for artifacts and datasets written by ClearML.

5. **KMS Encryption:**  
   Server-side encryption is applied using the provided **KMS key alias**.

## The Contract: Variables and Outputs

### Variables (`variables.tf`)

This module requires **five mandatory inputs**, defining project identity, bucket naming, and encryption.

| Variable | Type | Description |
|-----------|------|-------------|
| `project_name` | string | Used for deterministic naming of the bucket prefix. |
| `environment` | string | Used for deterministic naming of the bucket prefix. |
| `region` | string | Used for deployment region tagging. |
| `bucket_names` | list(string) | List of storage volumes required by ClearML (`artifacts`, `datasets`, `logs`). |
| `kms_key_alias` | string | Alias for the AWS KMS key used for encryption. |

### Outputs (`outputs.tf`)

The single critical output is the **unique identifier for each storage volume**.

| Output | Type | Description |
|---------|------|-------------|
| `bucket_arns` | map(string) | Complete Amazon Resource Name (ARN) for each bucket, keyed by its purpose (e.g., `artifacts`, `logs`). Used by the EKS and Ansible layers as the application’s secure storage address. |


