# Terraform Validation Lab: Ubuntu 24.04 Setup

### Lab Objective

This guide provides the steps to install necessary tools and perform local syntax and dry-run validation on the generated Terraform IaC artifact before deployment.

### Procedure

1. Install necessary dependencies from hasiicorp repo for the kubeconfig generation in the eks module.

    `student@bchd:~$` `sudo apt update`

    `student@bchd:~$` `sudo apt install -y curl unzip apt-transport-https software-properties-common`

0. We will use the official HashiCorp repository for the most stable and up-to-date installation method. Add the HashiCorp GPG key:

    `student@bchd:~$` `curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg`

0. Add the HashiCorp repository:

    `student@bchd:~$` `echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com jammy main" | sudo tee /etc/apt/sources.list.d/hashicorp.list`

0. Update and install Terraform:

    `student@bchd:~$` `sudo apt update`

    `student@bchd:~$` `sudo apt install terraform`

0. Verify installation:

    `student@bchd:~$` `terraform --version`

