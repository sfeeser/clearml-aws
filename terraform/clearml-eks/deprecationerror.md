Below is the **minimal, copy‑paste fix** that will **eliminate the new `s3:GetBucketAcl` error** (and keep the previous permission fixes).

---

## 1. Add the missing S3 action to your IAM policy

### If you are using **the custom policy** (recommended)

Open **IAM → Policies → `Terraform-EKS-ClearML-FullAccess`** → **Edit policy → JSON** and **add `s3:GetBucketAcl`** to the S3 block:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    { ... existing EC2/EKS/IAM/KMS block ... },
    {
      "Effect": "Allow",
      "Action": [
        "s3:CreateBucket",
        "s3:DeleteBucket",
        "s3:PutBucketPolicy",
        "s3:DeleteBucketPolicy",
        "s3:GetBucketPolicy",
        "s3:GetBucketAcl",          // ← NEW
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

**Save** → **Re‑attach** to `iac-runner` if needed.

---

### If you are using **AdministratorAccess** (quick sandbox fix)

You already have `s3:*`, so **skip this step** – the error would not appear.

---

## 2. (Optional but recommended) Use `aws_s3_bucket_acl` instead of the old `aws_s3_bucket` ACL block

The EKS module v20+ prefers the **separate ACL resource** to avoid the `GetBucketAcl` call during reads.

### Replace the bucket block in `helm-clearml.tf`

```hcl
# --- old (causes GetBucketAcl) ---
# resource "aws_s3_bucket" "clearml_artifacts" { ... }

# --- NEW: separate bucket + ACL ---
resource "random_pet" "bucket_suffix" {
  length = 2
}

resource "aws_s3_bucket" "clearml_artifacts" {
  bucket        = "clearml-artifacts-${var.cluster_name}-${random_pet.bucket_suffix.id}"
  force_destroy = true
}

resource "aws_s3_bucket_acl" "clearml_artifacts_acl" {
  bucket = aws_s3_bucket.clearml_artifacts.id
  acl    = "private"
}

resource "aws_s3_bucket_versioning" "clearml_artifacts" {
  bucket = aws_s3_bucket.clearml_artifacts.id
  versioning_configuration {
    status = "Enabled"
  }
}
```

> **Add `random` provider** (if not already in `versions.tf`):

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

## 3. Clean up any stale state (the bucket that already exists)

```bash
# Remove the old bucket reference from state
terraform state rm aws_s3_bucket.clearml_artifacts || true

# Re‑import the new bucket after apply (optional)
# terraform import aws_s3_bucket.clearml_artifacts clearml-artifacts-<name>
```

---

## 4. Run the plan again

```bash
terraform init -upgrade   # (if you added random provider)
terraform plan
```

You should now see **no permission errors** and **no deprecation warnings**.

---

## TL;DR – One‑liner for the IAM fix

```bash
# Add this line to your custom policy’s S3 action list:
"s3:GetBucketAcl",
```

---

**You’re done.**  
Run `terraform plan` → clean → `terraform apply` → **ClearML will be up in ~15 min**.

When it’s live, just say **`GO`** and I’ll give you the final access + destroy script.
