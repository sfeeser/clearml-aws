## SAAYN Terraform Validation Lab: Ubuntu 24.04 Setup

This guide provides the steps to install necessary tools and perform local syntax and dry-run validation on the generated Terraform IaC artifact before deployment.

1. Install necessary dependencies from hasiicorp repo for the kubeconfig generation in the eks module.

    ```
    sudo apt update
    sudo apt install -y curl unzip apt-transport-https software-properties-common awscli
    ```

2. Add the HashiCorp GPG key:

    ```
    curl -fsSL [https://apt.releases.hashicorp.com/gpg](https://apt.releases.hashicorp.com/gpg) | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
    ```

3. Add the HashiCorp repository:

    ```
    echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] [https://apt.releases.hashicorp.com](https://apt.releases.hashicorp.com) jammy main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
    ```

4. Update and install Terraform:

    ```
    sudo apt update
    sudo apt install terraform
    ```


5. Verify installation:

    ```
    terraform --version
    ```
