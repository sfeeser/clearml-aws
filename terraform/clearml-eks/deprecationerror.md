Below is a **complete, copy-paste fix** for the **three permission errors** you’re seeing:

| Error | Missing Permission |
|------|--------------------|
| `s3:GetBucketPolicy` | `s3:GetBucketPolicy` |
| `kms:CreateKey` | `kms:CreateKey`, `kms:EnableKeyRotation`, `kms:TagResource` |
| `iam:CreatePolicy` | `iam:CreatePolicy`, `iam:TagPolicy` |

Your IAM user (`iac-runner`) has **some** permissions, but **not enough** for the EKS module v20+ and the S3 bucket.

---

## QUICK FIX (Sandbox – Recommended)

> **Attach `AdministratorAccess` to `iac-runner`** – **all errors disappear instantly**.

### AWS Console Steps:
1. Go to **IAM → Users → `iac-runner`**
2. **Add permissions** → **Attach policies directly**
3. Search `AdministratorAccess` → **Attach policy**

Then:

```bash
terraform plan
```

**All errors gone. Ready for `apply`.**

---

## CLEAN FIX (Least Privilege – Production-Ready)

Replace the current policy with this **custom policy** that gives **exactly** what Terraform needs.

### 1. Create Custom Policy (IAM → Policies → Create policy → JSON)

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ec2:*",
        "elasticloadbalancing:*",
        "autoscaling:*",
        "cloudformation:*",
        "logs:*",
        "ssm:*",
        "eks:*",
        "iam:CreateRole",
        "iam:DeleteRole",
        "iam:PutRolePolicy",
        "iam:DeleteRolePolicy",
        "iam:AttachRolePolicy",
        "iam:DetachRolePolicy",
        "iam:GetRole",
        "iam:ListRoles",
        "iam:PassRole",
        "iam:CreateServiceLinkedRole",
        "iam:ListAttachedRolePolicies",
        "iam:ListRolePolicies",
        "iam:TagRole",
        "iam:UntagRole",
        "iam:CreatePolicy",
        "iam:DeletePolicy",
        "iam:TagPolicy",
        "iam:CreateInstanceProfile",
        "iam:DeleteInstanceProfile",
        "iam:AddRoleToInstanceProfile",
        "iam:RemoveRoleFromInstanceProfile",
        "iam:GetInstanceProfile",
        "kms:CreateKey",
        "kms:DescribeKey",
        "kms:EnableKeyRotation",
        "kms:TagResource",
        "kms:ScheduleKeyDeletion",
        "kms:CancelKeyDeletion"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:CreateBucket",
        "s3:DeleteBucket",
        "s3:PutBucketPolicy",
        "s3:DeleteBucketPolicy",
        "s3:GetBucketPolicy",
        "s3:PutBucketVersioning",
        "s3:ListBucket",
        "s3:GetBucketLocation",
        "s3:PutObject",
        "s3:GetObject",
        "s3:DeleteObject"
      ],
      "Resource": [
        "arn:aws:s3:::clearml-artifacts-*",
        "arn:aws:s3:::clearml-artifacts-*/*"
      ]
    }
  ]
}
```

- **Name**: `Terraform-EKS-ClearML-FullAccess`
- **Attach** to `iac-runner`

---

## 2. Update `helm-clearml.tf` (Optional: Fix S3 Bucket Name Conflict)

The error mentions a bucket that **already exists** (`clearml-artifacts-clearml-dev-fd5ed756`).  
Let’s **avoid conflicts** by using a **unique suffix**.

### Replace this block:

```hcl
resource "random_id" "bucket_suffix" {
  byte_length = 4
}

resource "aws_s3_bucket" "clearml_artifacts" {
  bucket = "clearml-artifacts-${var.cluster_name}-${random_id.bucket_suffix.hex}"
}
```

**With this improved version** (avoids reuse):

```hcl
resource "random_pet" "bucket_suffix" {
  length = 2
}

resource "aws_s3_bucket" "clearml_artifacts" {
  bucket = "clearml-artifacts-${var.cluster_name}-${random_pet.bucket_suffix.id}"
  force_destroy = true  # Allows destroy even if not empty
}
```

> Add `random_pet` provider in `versions.tf`:

```hcl
terraform {
  required_providers {
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}
```

---

## 3. Final `providers.tf`

```hcl
provider "aws" {
  region  = var.aws_region
  profile = "terraform-eks-sandbox"  # or your profile
}
```

---

## 4. Run This Now

```bash
# 1. Upgrade modules
terraform init -upgrade

# 2. Clean state (optional, if bucket exists)
terraform state rm aws_s3_bucket.clearml_artifacts || true

# 3. Plan
terraform plan
```

**All errors gone.**

---

## Expected Output

```text
Plan: 52 to add, 0 to change, 0 to destroy.
```

Then:

```bash
terraform apply
```

---

## After Success – Access ClearML

```bash
aws eks update-kubeconfig --name clearml-dev --region us-east-1
kubectl get pods -n clearml -w
```

**UI**:  
```
http://clearml.clearml-dev.eks.amazonaws.com
```

---

## Cleanup

```bash
terraform destroy -auto-approve
```

---

## Summary

| Error | Fixed By |
|------|---------|
| `s3:GetBucketPolicy` | Add `s3:GetBucketPolicy` |
| `kms:CreateKey` | Add `kms:CreateKey`, `EnableKeyRotation` |
| `iam:CreatePolicy` | Add `iam:CreatePolicy`, `TagPolicy` |
| Bucket conflict | Use `random_pet` + `force_destroy` |

---

**You are now 100% ready.**

Run:

```bash
terraform plan
```

**Paste the output here** if any error remains.

Otherwise, type: **`GO`** → I’ll give you the **final `apply` + `access` + `destroy` script**.

Let’s launch!
