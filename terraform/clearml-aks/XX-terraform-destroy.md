# Terraform Apply

***STOP: PLEASE READ BEOFRE YOU PROCEED***  
***STOP: PLEASE READ BEOFRE YOU PROCEED***  
***STOP: PLEASE READ BEOFRE YOU PROCEED***  

The `terraform destroy` command is the direct opposite of `terraform apply`. It is how you tear down your infrastructure. When you run the command, Terraform will first connect to your Azure subscription and generate a "destroy plan." This is a preview list of every resource that will be deleted. You will be prompted to confirm you want to proceed. You must type yes and press Enter.

What Happens When You Run Destroy?
If it Succeeds: Terraform will delete all your resources from Azure in the correct order. Once the "Destroy complete!" message appears, your infrastructure is gone from the Azure portal. You will stop incurring charges for those specific resources (since they no longer exist).

If it Fails: Yes, a destroy can fail. This might happen due to permission errors (e.g., your credentials don't allow deleting a resource) or because a resource is "locked" in the Azure portal. We should be fine in our environment as long as you followed the steps to create everything needed. This has been tried and true in testing. 

Costs if it Fails: If the destroy fails, you are still paying for any resources that were not successfully deleted. Terraform will try to remove as much as it can, but any "orphaned" resources (like a VNet or a Public IP) that are left behind in your account will continue to cost you money. You would then need to either fix the error and run terraform destroy again or log in to the Azure portal and delete the remaining resources manually.

Note: 


### Lab Objective

The objective of this lab is to properly clean up your sandbox environment and **stop incurring costs**. You will use the terraform destroy command to delete all the live Azure resources that you created with terraform apply. This teaches you the final part of the infrastructure lifecycle: decommissioning.


### Procedure

1. Change into the *aks* directory where we will be doing the work for the Azure labs.

    `student@bchd:~$` `cd ~/clearml-aws/terraform/clearml-aks`

0. **WAIT WAIT**. This next step is where you start burning the bills. It creates the actual infrastructure up in your Azure tenant. 

0. Run the terraform destroy command. **You need to be logged into your cloud provider for this to function.**

    `student@bchd:~/clearml-aws/terraform/clearml-aks$` `terraform destroy`

    > You should also (just like `terraform apply`) be prompted to approve the DESTRUCTION of your resources in your Azure subscription.


**Notes of Prominence**. 

- Running `terraform destroy` will **NOT** destroy everything.

- Terraform's "scope" is strictly defined by its provider configuration. When you run terraform plan or apply, you are "logged in" to a specific subscription defined in your provider "azurerm" {} block (or set by your az login command).

- Terraform is completely "blind" to any other subscriptions you might own unless you explicitly add another provider block with a different subscription ID.

- Even more importantly, terraform destroy only targets resources that are listed in its state file.
  - If a resource (like a VM or a VNet) is not on that list, terraform destroy does not know it exists and cannot touch it.
  - This is true even for resources within the same subscription. If you created a virtual machine manually in the Azure portal, terraform destroy will not (and cannot) delete it.
