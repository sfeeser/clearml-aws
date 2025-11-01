# ClearML on AWS — Demo Edition  

### Overview

This repository contains a complete, reproducible environment for deploying **ClearML Enterprise** on **AWS**.  
It provides two coordinated layers:

| Layer | Tool | Role |
|--------|------|------|
| **Infrastructure** | Terraform | Creates the AWS foundation (VPC, EKS, S3, IAM, ACM). |
| **Configuration** | Ansible + Helm | Installs ClearML services inside the Kubernetes cluster. |

These layers are **semantically defined** and self-describing through the [SAAYN Manifesto](saayn/manifesto.md).

### Repository Layout

```

clearml-aws/
├─ saayn/                    # Semantic source (SpecBooks + Manifesto)
│  ├─ manifesto.md
│  ├─ specbook-terraform.md
│  └─ specbook-ansible.md
│
├─ spec/                     # Shared configuration file
│  └─ config.yaml
│
├─ terraform/                # Infrastructure-as-Code (AWS provisioning)
│  ├─ stacks/aws-clearml/
│  └─ modules/
│
├─ ansible/                  # Application configuration layer
│  ├─ playbooks/
│  ├─ roles/clearml/
│  └─ inventories/example/
│
├─ scripts/                  # Utility scripts
│  └─ empty-bucket.sh
│
├─ Makefile                  # Unified command interface
└─ README.md                 # You are here

```

### Quickstart

### 1. Clone this repo
```bash
git clone https://github.com/sfeeser/clearml-aws.git
cd clearml-aws
```

### 2. Configure environment

Edit [`spec/config.yaml`](spec/config.yaml) to match your demo or class environment:

```yaml
aws:
  region: us-east-1
  vpc:
    cidr_block: 10.20.0.0/16
    az_count: 3
  dns_tls:
    enable: false  # or true if using Route53 + ACM
```

You can keep the defaults for demo use.


### ⚙️ Infrastructure (Terraform)

### Initialize

```bash
make init
```

#### Plan and apply

```bash
make apply
```

Terraform provisions:

* VPC, subnets, routing, gateways
* EKS cluster and nodegroups
* IAM and IRSA roles
* S3 buckets for artifacts, datasets, and logs
* Optional ACM certificate and Route53 DNS entry

#### View results

```bash
terraform -chdir=terraform/stacks/aws-clearml output
```

#### Destroy when finished

```bash
make destroy
```

> 🧹 The `destroy` step ensures your AWS sandbox returns to **zero cost**.
> Demo buckets use `force_destroy = true` for safety.

### ⚙️ Application (Ansible + Helm)

After the Terraform infrastructure is ready:

### 1. Export kubeconfig

```bash
export KUBECONFIG=$(terraform -chdir=terraform/stacks/aws-clearml output -raw kubeconfig_path)
```

### 2. Deploy ClearML

```bash
cd ansible
ansible-playbook -i inventories/example/hosts.yml playbooks/site.yml
```

Ansible:

* Creates a namespace (`clearml`)
* Renders Helm values from your config
* Installs ClearML via Helm
* Runs basic readiness checks

### 3. Verify deployment

```bash
kubectl get pods -n clearml
```

If ingress is enabled, note the public endpoint and access ClearML in your browser.

## Teaching Workflow

1. **Provision:** Run Terraform (`make apply`)
2. **Configure:** Run Ansible (`ansible-playbook`)
3. **Explore:** Students interact with ClearML and the cluster
4. **Teardown:** Run `make destroy`

Each step can be demonstrated live or assigned as lab exercises.

## Design Boundaries

| Responsibility           | Owner     | Tool              |
| ------------------------ | --------- | ----------------- |
| Cloud resources          | Terraform | AWS IaC           |
| In-cluster configuration | Ansible   | Helm + K8s        |
| Application lifecycle    | Ansible   | Helm releases     |
| Cost control / cleanup   | Terraform | Teardown workflow |

Terraform **creates and deletes**.
Ansible **configures and tests**.
They are complementary but never overlap.


### 🔗 Resources

* [ClearML.org](https://clearml.org)
* [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
* [Ansible Kubernetes Collection](https://docs.ansible.com/ansible/latest/collections/kubernetes/core/)
* [Alta3 Research](https://alta3.com)
* [SAAYN Manifesto](saayn/manifesto.md)

> *Specifications Are All You Need.*
> This repo proves it: intent, exemplar, artifact — all in one place.

```

