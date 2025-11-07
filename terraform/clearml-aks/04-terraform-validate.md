# Validate Terraform 

In this lab, after initializing the project with terraform init (which downloaded the required providers and modules), we execute the terraform validate command.

`terraform validate` loads all the .tf files in the directory and performs a static analysis. It checks code against the provider schemas loaded during init to ensure:

- All syntax was valid HCL.
- All resource and module blocks contained the correct arguments.
- All variable references were valid.

### Lab Objective

The primary objective of running terraform validate is to verify the syntactic and logical correctness of the Terraform configuration before attempting to generate an execution plan.

This step is designed to catch simple typos and structural errors quickly and locally, without wasting time or API calls trying to connect to the cloud.


### Procedure

1. Change into the *aks* directory where we will be doing the work for the Azure labs.

    `student@bchd:~$` `cd ~/clearml-aws/terraform/clearml-aks`

0. Run the terraform validate.

    `student@bchd:~/clearml-aws/terraform/clearml-aks$` `terraform validate`

    ```
    Success! The configuration is valid.
    ```

