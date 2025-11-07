# Terraform Validation Lab: Ubuntu 24.04 Setup

### Lab Objective

This guide provides the steps to install necessary tools and perform local syntax and dry-run validation on the generated Terraform IaC artifact before deployment.

### Procedure

1. Set your environmental variables (azure keys)

    ```shell
      export ARM_TENANT_ID="xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
      export ARM_SUBSCRIPTION_ID="11111111-1111-1111-1111-111111111111"
      export ARM_CLIENT_ID="aaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee"
      export ARM_CLIENT_SECRET="*****"
    ```

0. Install the azure cli to login.

    `student@bchd:~$` `curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash`

0. Log in. 

    `student@bchd:~$` `az login`

0. Take a look at your account

    `student@bchd:~$` `az account show`

0. check options for resources

   `student@bchd:~$` `az account list --output table`

   `student@bchd:~$` `az vm list-skus --location eastus --all   --output table`


