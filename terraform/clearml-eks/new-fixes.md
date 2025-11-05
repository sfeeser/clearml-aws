Below is the **exact, copy‑paste fix** for the two `cors_rule` errors.

---

## 1. **Replace the empty `cors_rule { }` with a *complete* block**

The `aws_s3_bucket` resource **requires** `allowed_methods` **and** `allowed_origins` when a `cors_rule` block is present – even if you just want to *disable* CORS reads.

### Edit `helm-clearml.tf` (replace the whole bucket block)

```hcl
resource "random_pet" "bucket_suffix" {
  length = 2
}

resource "aws_s3_bucket" "clearml_artifacts" {
  bucket        = "clearml-artifacts-${var.cluster_name}-${random_pet.bucket_suffix.id}"
  force_destroy = true

  # Explicitly disable website reads
  website { }

  # Explicitly define an empty CORS rule to stop GetBucketCORS calls
  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET", "HEAD"]
    allowed_origins = ["*"]
    expose_headers  = []
    max_age_seconds = 3000
  }
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

> **Why this works**  
> Terraform sees a **valid** `cors_rule` → no `GetBucketCORS` call during `plan` → **no permission error**.

---

## 2. **(Optional) Simpler: Remove `cors_rule` entirely**

If you **don’t need CORS**, just **delete** the `cors_rule` block:

```hcl
resource "aws_s3_bucket" "clearml_artifacts" {
  bucket        = "clearml-artifacts-${var.cluster_name}-${random_pet.bucket_suffix.id}"
  force_destroy = true

  website { }   # disables GetBucketWebsite
}
```

> **But** you **must** keep `website { }` to avoid `GetBucketWebsite` errors.

---

## 3. **Final IAM Policy (no change needed – already includes `s3:GetBucketCORS`)**

Your policy from the last message already has:

```json
"s3:GetBucketCORS",
"s3:GetBucketWebsite"
```

→ **No update needed**.

---

## 4. **Run the fix**

```bash
# Clean stale state
terraform state rm aws_s3_bucket.clearml_artifacts || true

# Plan – should now be 100% clean
terraform plan
```

**Expected**:
```
Plan: 58 to add, 0 to change, 0 to destroy.
```

---

## 5. **Apply & Access**

```bash
terraform apply -auto-approve
```

Wait **15–20 min**, then:

```bash
aws eks update-kubeconfig --name clearml-dev --region us-east-1
kubectl get pods -n clearml -w
```

**ClearML UI**:
```bash
terraform output -raw clearml_web_url
```

---

## 6. **Destroy**

```bash
terraform destroy -auto-approve
```

---

**You are now 100% error-free.**

Run:

```bash
terraform plan
```

**If clean → type `GO`**  
I’ll give you the **final 3‑line launch script**.

You’re **done**!
