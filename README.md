# ClearML on AWS — Demo Edition  
Author: Stuart Feeser  
Organization: Alta3 Research (https://alta3.com)

## Overview

This repository provides a complete, reproducible environment for deploying ClearML Enterprise on AWS using two coordinated automation layers:

| Layer | Tool | Role |
|--------|------|------|
| Infrastructure | Terraform | Provisions the AWS foundation (VPC, EKS, S3, IAM, ACM). |
| Configuration | Ansible + Helm | Installs ClearML services into the Kubernetes cluster. |

These layers are defined semantically through the SAAYN Manifesto (see saayn/manifesto.md).

### Step-by-Step Instructions

1. Create or designate an AWS sandbox account dedicated to classroom or demo use.

   Why use a sandbox:
   - Keeps training costs isolated from production billing.
   - Allows full cleanup by deleting the account after class.
   - Enables safe experimentation with IAM and Kubernetes roles.

   Quick sandbox setup (recommended):
   - Sign in as the AWS root account owner.
   - Create a new member account under AWS Organizations.
   - Name it something like clearml-demo-sandbox.
   - Grant administrative access to your instructor IAM user or role.
   - Set a budget alert (for example, $50) in the AWS Billing Console under Budgets.

   At the end of the demo, delete the sandbox account to remove all resources automatically.

2. Install prerequisites on your workstation (tested on Ubuntu 24.04):

   | Tool | Minimum Version | Purpose |
   |------|-----------------|----------|
   | Terraform | 1.7 or newer | Infrastructure provisioning |
   | AWS CLI | v2 | Authentication and IAM |
   | kubectl | Matches EKS minor version | Kubernetes client |
   | Helm | v3 | Application charts |
   | Ansible | 2.16 or newer | Configuration and Helm automation |
   | jq, make | - | Helper utilities |

   Install Ansible collections:
   ```bash
   ansible-galaxy collection install kubernetes.core community.kubernetes
   ```

3. Configure AWS credentials:

   ```bash
   aws configure
   # or use environment variables:
   export AWS_PROFILE=<profile_name>
   export AWS_REGION=us-east-1
   ```

4. Clone this repository:

   ```bash
   git clone https://github.com/sfeeser/clearml-aws.git
   cd clearml-aws
   ```

5. Edit spec/config.yaml to match your sandbox region and naming:

   ```yaml
   aws:
     region: us-east-1
     vpc:
       cidr_block: 10.20.0.0/16
       az_count: 3
     dns_tls:
       enable: false  # or true if using Route53 + ACM
   ```

   Note: S3 bucket names must be globally unique across all AWS users.

6. Initialize Terraform:

   ```bash
   make init
   ```

7. (Optional) Preview the Terraform plan:

   ```bash
   make plan
   ```

8. Apply the Terraform configuration:

   ```bash
   make apply
   ```

9. Terraform provisions the following resources:

   * VPC, subnets, routing, and gateways
   * EKS cluster and nodegroups
   * IAM and IRSA roles
   * S3 buckets for artifacts, datasets, and logs
   * Optional ACM certificate and Route53 DNS entry

10. View Terraform outputs:

    ```bash
    terraform -chdir=terraform/stacks/aws-clearml output
    ```

11. Export the kubeconfig path:

    ```bash
    export KUBECONFIG=$(terraform -chdir=terraform/stacks/aws-clearml output -raw kubeconfig_path)
    kubectl get nodes
    # Verify that the cluster is reachable before continuing
    ```

12. Deploy ClearML into the cluster using Ansible:

    ```bash
    cd ansible
    ansible-playbook -i inventories/example/hosts.yml playbooks/site.yml
    ```

13. Ansible performs the following:

    * Creates the namespace "clearml"
    * Renders Helm values from spec/config.yaml
    * Installs ClearML via Helm
    * Runs readiness checks

14. Verify the ClearML deployment:

    ```bash
    kubectl get pods -n clearml
    kubectl get svc -n clearml
    ```

    If ingress is enabled:

    ```bash
    kubectl get ingress -n clearml
    ```

    Visit the listed hostname or load balancer URL in your browser.

15. (Optional) Uninstall ClearML before teardown:

    ```bash
    kubectl delete ns clearml --ignore-not-found --wait=true
    ```

16. Destroy all AWS infrastructure:

    ```bash
    make destroy
    ```

    The destroy step ensures your AWS sandbox returns to zero cost.
    Demo buckets use force_destroy = true for safe cleanup.

## Design Boundaries

| Responsibility           | Owner     | Tool              |
| ------------------------ | --------- | ----------------- |
| Cloud resources          | Terraform | AWS IaC           |
| In-cluster configuration | Ansible   | Helm + K8s        |
| Application lifecycle    | Ansible   | Helm releases     |
| Cost control / cleanup   | Terraform | Teardown workflow |

Terraform creates and deletes.
Ansible configures and tests.
They are complementary but never overlap.


## Troubleshooting

| Symptom                     | Likely Cause                    | Fix                                         |
| --------------------------- | ------------------------------- | ------------------------------------------- |
| Error creating S3 bucket    | Bucket name not unique          | Edit names in spec/config.yaml              |
| kubectl cannot connect      | Missing or incorrect KUBECONFIG | Re-export from Terraform output             |
| terraform destroy hangs     | ALB or namespace still exists   | Delete the clearml namespace before destroy |
| Namespace stuck Terminating | Finalizers blocking deletion    | Remove finalizers and retry                 |
| Unexpected AWS charges      | Cluster left running            | Always use sandbox account; verify teardown |

## References

* ClearML: [https://clearml.org](https://clearml.org)
* Terraform AWS Provider: [https://registry.terraform.io/providers/hashicorp/aws/latest/docs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
* Ansible Kubernetes Collection: [https://docs.ansible.com/ansible/latest/collections/kubernetes/core/](https://docs.ansible.com/ansible/latest/collections/kubernetes/core/)
* Alta3 Research: [https://alta3.com](https://alta3.com)
* SAAYN Manifesto: saayn/manifesto.md

