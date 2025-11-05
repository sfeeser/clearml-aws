You're seeing this **deprecation warning** because the **Terraform AWS EKS module** you're using (likely version `~> 19.0`) is using the deprecated `inline_policy` argument in its internal `aws_iam_role` resource.

> **Good news**: This is **just a warning**, not an error.  
> **Your `terraform plan` and `apply` will still work perfectly.**

But you want to **eliminate the warning** — clean code, future-proofing. Let's fix it **permanently**.

---

## Root Cause

The EKS module creates IAM roles like this (simplified):

```hcl
resource "aws_iam_role" "this" {
  name = "eks-cluster-role"
  assume_role_policy = "..."

  inline_policy {
    name   = "eks-policy"
    policy = jsonencode({...})
  }
}
```

The `inline_policy {}` block is **deprecated** in the AWS provider v5+.

---

## Solution: **Upgrade the EKS Module to v20+**

The **official fix** is to **upgrade** the `terraform-aws-modules/eks/aws` module to **version 20 or higher**, which:

- Removes `inline_policy`
- Uses `aws_iam_role_policy` instead
- Eliminates the warning

---

### Step-by-Step Fix

#### 1. **Update `eks-cluster.tf`**

Change this line:

```hcl
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 19.0"   # ← OLD
  # ...
}
```

**Replace with**:

```hcl
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"   # ← NEW: Fixes deprecation
  # ... rest of config unchanged
}
```

---

#### 2. **Upgrade Providers & Modules**

Run:

```bash
terraform init -upgrade
```

This will:
- Download the new EKS module (v20+)
- Update provider constraints if needed

---

#### 3. **Run Plan Again**

```bash
terraform plan
```

**The warning will be GONE.**

---

## Why This Works

| Version | `inline_policy` | Status |
|--------|------------------|--------|
| `~> 19.0` | Used | **Deprecated** → warning |
| `~> 20.0` | Removed | **Clean** → no warning |

> See official changelog:  
> https://github.com/terraform-aws-modules/terraform-aws-eks/releases/tag/v20.0.0

---

## Bonus: Confirm It’s Fixed

After upgrade, check:

```bash
terraform plan | grep -i "deprecated"
```

→ Should return **nothing**.

---

## Final Code Snippet (Updated)

```hcl
# eks-cluster.tf
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"   # ← This removes the warning

  cluster_name                    = var.cluster_name
  cluster_version                 = var.kubernetes_version
  vpc_id                          = module.vpc.vpc_id
  subnet_ids                      = module.vpc.private_subnets
  cluster_endpoint_public_access  = true

  eks_managed_node_groups = {
    clearml = {
      desired_size   = var.desired_nodes
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
    }
  }

  tags = {
    Environment = "dev"
  }
}
```

---

## Summary

| Action | Command |
|-------|--------|
| **Fix warning** | Change `version = "~> 19.0"` → `version = "~> 20.0"` |
| **Apply fix** | `terraform init -upgrade` |
| **Verify** | `terraform plan` → no deprecation warnings |

---

**You’re now running clean, future-proof Terraform.**

Next: Run `terraform apply` in your **sandbox account** — and let me know when it’s up! I’ll help you:
- Access the ClearML UI
- Add HTTPS
- Destroy safely

**Clean code, zero warnings, full control.** You're golden!
