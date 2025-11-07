# Initialize Terraform 

`terraform init` is a setup command that prepares your working directory to run Terraform commands. It's like checking the "instruction manual" for your project, downloading all the necessary tools and blueprints, and setting up your workspace before you start the build process. 

You must run init as the very first step when you start a new Terraform project or check out an existing one.

To actually talk to cloud services like AWS, Azure, or Google Cloud, it needs plugins called Providers. We'll get to that soon. `terraform init` reads your configuration (like providers.tf), finds out which providers you need (e.g., hashicorp/aws), and typically downloads them into a hidden .terraform folder.

### Lab Objective

Initialize the backend where Terraform stores its state file which is simply a JSON map of your infrastructure.

### Procedure

1. Clone the terraform clearml repo from github.

   `student@bchd:~$` `git clone https://github.com/sfeeser/clearml-aws.git`

0. Change into the *aks* directory where we will be doing the work for the Azure labs.

    `student@bchd:~$` `cd ~/clearml-aws/terraform/clearml-aks`

0. Run the terraform init.

    `student@bchd:~/clearml-aws/terraform/clearml-aks$` `terraform init`

    ```
    Initializing the backend...
    Initializing provider plugins...
    - Finding hashicorp/azurerm versions matching "~> 3.0"...
    - Installing hashicorp/azurerm v3.117.1...
    - Installed hashicorp/azurerm v3.117.1 (signed by HashiCorp)
    Terraform has created a lock file .terraform.lock.hcl to record the provider
    selections it made above. Include this file in your version control repository
    so that Terraform can guarantee to make the same selections by default when
    you run "terraform init" in the future.
    
    Terraform has been successfully initialized!
    
    You may now begin working with Terraform. Try running "terraform plan" to see
    any changes that are required for your infrastructure. All Terraform commands
    should now work.
    
    If you ever set or change modules or backend configuration for Terraform,
    rerun this command to reinitialize your working directory. If you forget, other
    commands will detect it and remind you to do so if necessary.
    ```

0. Terraform has been successfully initialized.

0. Verify the files are created.

    `student@bchd:~/clearml-aws/terraform/clearml-aks$` `ls -al`

    ```
    .terraform
    .terraform.lock.hcl
    main.tf
    ```

