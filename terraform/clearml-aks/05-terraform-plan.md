# Terraform Plan

In this lab, you will execute the `terraform plan` command. This is the most important safety step in the entire Terraform workflow. 
When you run this command, Terraform will connect to your Azure account and "refresh" its state. It will compare the infrastructure defined in your local .tf files with what actually exists in the cloud. Right now, if this is your first run through - is nothing.

You will then see a summary of the proposed plan, which should show a long list of resources to be "created" and none to be changed or destroyed. This output will confirm your code is valid, your permissions are working, and that you are safe to proceed to the apply step.

### Lab Objective

The objective of this lab is to generate your first execution plan. You will use the terraform plan command to:

- Verify Cloud Connection: Perform the first real connection to your Azure account. This step is the primary test to ensure your iac-runner credentials (from your "speed paste") are working correctly.

- Perform a "Dry Run": See a detailed preview of all the infrastructure resources that Terraform intends to create.

- Review for Safety: Learn how to read the plan output to confirm that the proposed changes match your expectations before you ever build anything.

### Procedure

1. Change into the *aks* directory where we will be doing the work for the Azure labs.

    `student@bchd:~$` `cd ~/clearml-aws/terraform/clearml-aks`

0. Run the terraform plan command. **You need to be logged into your cloud provider for this to function.**

    `student@bchd:~/clearml-aws/terraform/clearml-aks$` `terraform plan`

    ```
    Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:                                       
      + create          
    
    ...
    
    
    Plan: 6 to add, 0 to change, 0 to destroy.
    
    Changes to Outputs:
      + cluster_name   = "clearml-dev"
      + kubeconfig     = (sensitive value)
      + resource_group = "clearml-dev-rg"
    
    ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    
    Note: You didn't use the -out option to save this plan, so Terraform can't guarantee to take exactly these actions if you run "terraform apply" now.
        
    ```

0. **OPTIONAL**: You can run the terraform plan command again. This time with the -out="path" option to save state. That way, in the next step, you can use that as input for the **apply** command. **You need to be logged into your cloud provider for this to function.**

    `student@bchd:~/clearml-aws/terraform/clearml-aks$` `terraform plan -out="path-you-choose"`
