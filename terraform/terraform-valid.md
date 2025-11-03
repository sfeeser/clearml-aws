# Terraform Validation Lab: Ubuntu 24.04 Setup

### Lab Objective

This guide provides the steps to install necessary tools and perform local syntax and dry-run validation on the generated Terraform IaC artifact before deployment.

### Procedure

1. Install necessary dependencies from hasiicorp repo for the kubeconfig generation in the eks module.

    `student@bchd:~$` `sudo apt update`

    `student@bchd:~$` `sudo apt install -y curl unzip apt-transport-https software-properties-common awscli`

0. We will use the official HashiCorp repository for the most stable and up-to-date installation method. Add the HashiCorp GPG key:

    `student@bchd:~$` `curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg`

0. Add the HashiCorp repository:

    `student@bchd:~$` `echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com jammy main" | sudo tee /etc/apt/sources.list.d/hashicorp.list`

0. Update and install Terraform:

    `student@bchd:~$` `sudo apt update`

    `student@bchd:~$` `sudo apt install terraform`

0. Verify installation:

    `student@bchd:~$` `terraform --version`

0. Edit spec/config.yaml, found in the root directory of this repo as main.tf attempts to load it from there.

    ```
    # Minimal Mock Configuration for Local Validation
    
    project:
      name: clearml-saayn
      env: test
    
    aws:
      region: us-east-1
      vpc_cidr: 10.0.0.0/16
      eks_version: "1.28"
      dns_tls:
        enable: false # Must be false to skip ACM module creation
      
    s3:
      bucket_types:
        - artifacts
        - datasets
        - logs
      
    kms:
      alias: aws/ebs # Placeholder
    
    ansible:
      namespace: clearml # Required for IRSA module
    
    nodegroups:
      general-purpose:
        instance_types: ["t3.medium"]
        disk_size: 20
        desired_size: 1
        max_size: 2
        min_size: 1
    ```
