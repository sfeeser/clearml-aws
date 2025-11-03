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

0. Now you can test the code in the terraform/ directory structure created by your parser.sh script.

0.  Initialize the Terraform Backend and Providers. Navigate to the stack root and initialize Terraform. This downloads the providers (aws, kubernetes, helm) and validates the structure.

    ```
    cd terraform/stacks/aws-clearml
    terraform init
    ```

    **Expected Output:**

    ```
    Success message showing provider plugins have been successfully initialized.
    ```

0. Format and Syntax Check. Ensure the generated code is correctly formatted and passes the Terraform syntax check.
    
    ```bash
    terraform fmt -recursive -check
    ```

    **Expected Output:**

    ```
    Empty output (or a list of files if formatting is needed). The `-check` flag ensures no changes are applied.
    ```
    
0. Validate Configuration

    ```bash
    terraform validate
    ```

    **Expected Output:**

    ```
    Success! The configuration is valid
    ```


0.  ***Prerequisite:*** You must have configured your AWS credentials (e.g., via `aws configure` or environment variables) for the `terraform plan` to execute correctly, as it resolves data sources and performs API calls to look up roles/identities.

0. Perform a Dry Run. A `plan` is a dry run that attempts to resolve all data sources and variables, showing what actions *would* be taken against your configured AWS environment.

    ```bash
    terraform plan
    ```


    **Expected Output:**

    ```
    A detailed output listing the tens of resources (VPC, EKS, S3, IAM, etc.) that Terraform *intends*
    to create, followed by: `Plan: XX to add, 0 to change, 0 to destroy.`
    ```

0. If all these steps pass, your synthesized IaC artifact is verified as compliant and ready for deployment.

