# Configure Your Terraform Code

With our tools installed and our AWS account prepared, we just need to "connect" our local code to our cloud account. We'll do this by editing two files to tell Terraform where to store its state and what our personal IP address is.

### Lab Objective

You will edit two files (backend.tf and variables.tf) to tell Terraform where to store its state and what your specific IP address is for SSH access.

### Procedure


1. Get the Code Ensure you are in the project's terraform directory where the .tf files are located.

    `student@bchd:~$ cd ~/kubernetes-the-alta3-way/terraform`

0. Edit backend.tf Open this file in your text editor. Change the bucket value to the exact S3 bucket name you created in Phase 2.

    ```terraform
    terraform {
      backend "s3" {
        bucket  = "my-company-clearml-tfstate-20251107" # <-- YOUR BUCKET NAME
        key     = "clearml-eks/terraform.tfstate"
        region  = "us-east-1"
        encrypt = true
      }
    }
    ```

0. Edit variables.tf (Your IP Address) Open variables.tf and find the ssh_cidr variable. This is a security rule that only allows your IP to SSH to the cluster nodes.

0. First, find your IP by running this in your terminal:

    `student@bchd:~$` `curl ifconfig.me`

0. Now, edit the variables.tf file with that IP, adding /32 at the end.

    ```terraform
    variable "ssh_cidr" {
      description = "Your IP for SSH access (e.g., 203.0.113.10/32)"
      type        = string
      default     = "203.0.113.10/32" # <-- YOUR IP
    }
    ```

0. Edit the (Kubernetes Version) In the same variables.tf file, find the kubernetes_version variable and set its default value to your target version (e.g., "1.32").

    ```terraform
    variable "kubernetes_version" {
      description = "Target EKS version"
      type        = string
      default     = "1.32" # <-- Or your desired version
    }
    ```
