Below is a **complete, classroom-ready module** you can drop into your consultant training deck.  
It teaches **“Azure talk”** first (the concepts, the names, the mental model), then **hands over the exact `main.tf`** you already have.

---

## Module: “Azure Access & IaC – From Zero to Running Terraform”

| Time | Section | Goal |
|------|---------|------|
| 0-5 min | **Azure Identity & Billing Model** | Speak the language |
| 5-15 min | **RBAC, Service Principals & Secrets** | Replace AWS IAM keys |
| 15-20 min | **Azure Policy & Management Groups** | Guardrails = AWS Organizations + SCPs |
| 20-30 min | **Hands-On: Terraform in a Sandbox** | Deploy the cluster |

---

### 1. Azure Identity & Billing Model (5 min)

| AWS term | Azure term | What it **is** |
|----------|------------|----------------|
| **Account** | **Subscription** | Billing boundary + resource container |
| **Root Account** | **Tenant (Microsoft Entra ID)** | Directory of users, groups, apps |
| **IAM User** | **User / Group in Entra ID** | Human identity |
| **IAM Role** | **Role Assignment (RBAC)** | Permission set scoped to a resource |

> **Key phrase to teach:**  
> *“In Azure we **log in** with an **Entra ID account**, **pick a subscription** to work in, and **assign RBAC roles** to control what we can do.”*

---

### 2. RBAC, Service Principals & Secrets (10 min)

| AWS | Azure |
|-----|-------|
| **Access Key ID + Secret Key** | **Service Principal** (`client_id` + `client_secret`) |
| **IAM Policy** | **Azure RBAC Role** (`Contributor`, `Reader`, custom) |
| **AssumeRole** | **Role Assignment** at subscription/resource-group scope |

**Demo flow (live portal):**

1. **Create SP** → *Entra ID → App registrations → New → `iac-sandbox-runner`*  
2. **Add secret** → *Certificates & secrets → New client secret*  
3. **Assign role** → *Subscriptions → Sandbox-IaC-01 → Access control (IAM) → Add role assignment → Contributor → Select `iac-sandbox-runner`*

**Environment variables** (exact names Terraform expects):

```bash
export ARM_TENANT_ID="xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
export ARM_SUBSCRIPTION_ID="11111111-1111-1111-1111-111111111111"
export ARM_CLIENT_ID="aaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee"
export ARM_CLIENT_SECRET="*****"
```

> **Teach:** *“Never use your personal login for Terraform. Always use a Service Principal with **least-privilege** role on the **sandbox subscription**.”*

---

### 3. Azure Policy & Management Groups (5 min)

| AWS | Azure |
|-----|-------|
| **Organizations + SCP** | **Management Groups + Azure Policy** |
| **GuardDuty** | **Microsoft Defender for Cloud** |
| **Budgets** | **Cost Management → Budgets** |

**Quick demo:**

1. *Management groups → mg-sandboxes*  
2. *Azure Policy → Assignments → Create → Scope: mg-sandboxes → Policy: “Allowed VM SKUs” → Select only `Standard_D4s_v5`*  
3. *Cost Management → Budgets → + Create → Scope: Sandbox-IaC-01 → $100/month*

> **Phrase:** *“Management groups are your **folder structure** for subscriptions; Azure Policy is your **global guardrail**.”*

---

### 4. Hands-On: Terraform in a Sandbox (10 min)

> **“Now we speak Azure. Let’s deploy.”**

#### Step-by-step (copy-paste into lab guide)

```bash
# 1. Clone the repo
git clone https://github.com/yourorg/azure-iac-class.git
cd azure-iac-class

# 2. Create tfvars (never commit!)
cat > terraform.tfvars <<EOF
arm_subscription_id = "11111111-1111-1111-1111-111111111111"
arm_client_id       = "aaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee"
arm_client_secret   = "your-secret-here"
arm_tenant_id       = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
EOF

# 3. Initialize & apply
terraform init
terraform plan    # shows sandbox subscription
terraform apply -auto-approve
```

#### The **exact `main.tf`** (same as before – paste into slide)

```hcl
# main.tf – AKS in sandbox subscription
terraform {
  required_providers { azurerm = { source = "hashicorp/azurerm", version = "~> 3.0" } }
}

provider "azurerm" {
  features {}
  subscription_id = var.arm_subscription_id
  client_id       = var.arm_client_id
  client_secret   = var.arm_client_secret
  tenant_id       = var.arm_tenant_id
}

# ... [rest of the file from previous message] ...
```

#### Verify

```bash
terraform output -raw kubeconfig > ~/.kube/sandbox.config
kubectl --kubeconfig ~/.kube/sandbox.config get nodes
```

---

### Wrap-Up Slide

| Concept | Azure Term | AWS Analog |
|---------|------------|------------|
| Identity directory | **Tenant (Entra ID)** | Root account |
| Billing unit | **Subscription** | AWS Account |
| Human login | **User/Group** | IAM User |
| Automation identity | **Service Principal** | IAM Role + Access Keys |
| Permissions | **RBAC Role Assignment** | IAM Policy |
| Org hierarchy | **Management Group** | AWS Organizations |
| Guardrails | **Azure Policy** | Service Control Policies |

> **Final mantra:**  
> *“Speak Azure: **Tenant → Subscription → RBAC → Service Principal → Terraform**.”*

---

**Copy the sections above into your training deck.**  
The flow is: **talk → demo → code → deploy**.  
Your consultants will leave knowing **both the language and the muscle memory**.
