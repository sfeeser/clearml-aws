## 📘 `saayn/specbook-terraform.md`

```markdown
# SpecBook: ClearML AWS Infrastructure Foundation
Version: draft-01  
Author: Stuart Feeser (Alta3 Research)  
Layer: Infrastructure-as-Code (IaC)  
SAAYN Domain: Terraform

---

## 1. Intent

This SpecBook defines the **Infrastructure-as-Code foundation** required to host ClearML Enterprise on AWS.

The intent is to provision deterministic, fully tear-downable AWS resources that form the substrate on which ClearML will later be deployed by Ansible.  
This layer owns **creation and destruction**, while higher layers (Ansible, Helm) own configuration.

**Guiding principles:**

- Terraform is the *single source of truth* for AWS resources.
- All infrastructure must be idempotent, versioned, and teardown-safe.
- Ansible may consume Terraform outputs, but may never alter Terraform-managed resources.
- `terraform destroy` must return the environment to a zero-cost state.

---

## 2. Exemplar

### 2.1 Directory Topology

The compiler must emit this structure under the repository root:

```

terraform/
├─ stacks/aws-clearml/
│  ├─ main.tf
│  ├─ providers.tf
│  └─ variables.tf
└─ modules/
├─ vpc/
│  ├─ main.tf
│  ├─ variables.tf
│  └─ outputs.tf
├─ eks/
│  ├─ main.tf
│  ├─ variables.tf
│  └─ outputs.tf
├─ nodegroups/
│  ├─ main.tf
│  ├─ variables.tf
│  └─ outputs.tf
├─ irsa/
│  ├─ main.tf
│  ├─ variables.tf
│  └─ outputs.tf
├─ s3/
│  ├─ main.tf
│  ├─ variables.tf
│  └─ outputs.tf
└─ acm/
├─ main.tf
├─ variables.tf
└─ outputs.tf

```

### 2.2 Required Inputs

- **Configuration file:** `spec/config.yaml`
- **YAML structure:**
  - Defines project name, environment, region, VPC CIDR, nodegroups, S3 buckets, KMS key alias, and observability settings.
  - Terraform reads this file using `yamldecode(file(var.config_path))`.

### 2.3 Required Outputs

Terraform stack must emit these outputs:

| Output | Description |
|--------|--------------|
| `vpc_id` | The VPC identifier |
| `private_subnets` | IDs of private subnets |
| `cluster_name` | EKS cluster name |
| `cluster_endpoint` | EKS control-plane endpoint |
| `kubeconfig_path` | Path to generated kubeconfig |
| `s3_artifacts`, `s3_datasets`, `s3_logs` | S3 bucket ARNs |
| `certificate_arn` | (optional) ACM certificate ARN when DNS/TLS enabled |

---

## 3. Artifact

### 3.1 Artifact Type

- **Artifact:** Packfile or TAR (as defined in `saayn/manifest.yaml`)
- **Output Name:** `clearml-aws-terraform-v1.pack` or `.tar.gz`
- **Root Directory:** `terraform/`

### 3.2 File Composition Rules

1. All `.tf` files must be valid HCL syntax.
2. `Makefile` and helper scripts (e.g., `scripts/empty-bucket.sh`) may live outside `terraform/`.
3. Executable permissions (0755) must be set on shell scripts.

### 3.3 Execution Semantics

To deploy:

```bash
make init
make apply
````

To destroy:

```bash
make destroy
```

Terraform’s backend is assumed to be **local** for demo use; remote backends may be introduced later.

---

## 4. Determinism Requirements

* Terraform plans must produce the same resource graph given identical `spec/config.yaml`.
* All bucket and cluster names must derive from deterministic interpolation of `project_name` and `env`.
* S3 demo buckets must include `force_destroy = true` to ensure full teardown.
* `terraform destroy` must complete without residual AWS resources.
* State files are excluded from version control (`.gitignore`).

---

## 5. Validation Criteria

A SpecBook-compliant artifact passes validation if:

1. `terraform validate` and `terraform fmt -check` succeed with no errors.
2. The directory structure matches the exemplar exactly.
3. All required outputs exist in the root module.
4. Destroy completes with zero active AWS resources.

---

## 6. Relationship to Other Layers

This SpecBook is consumed by the next layer:
**`saayn/specbook-ansible.md`**, which uses Terraform outputs (`kubeconfig_path`, `cluster_name`, `s3_*`) as Ansible inputs.

---

## 7. Provenance

* Author: Stuart Feeser
* Organization: Alta3 Research
* Spec lineage: SAAYN v1.0 Semantic Purity Framework
* Last modified: {{ now }}
