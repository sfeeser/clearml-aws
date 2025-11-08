# Terraform Apply

***STOP: PLEASE READ BEOFRE YOU PROCEED***  
***STOP: PLEASE READ BEOFRE YOU PROCEED***  
***STOP: PLEASE READ BEOFRE YOU PROCEED***  

Running the `terraform apply` command is the final and most important step, where your infrastructure is actually built and **COST YOU MONEY** right out of the gate. When you run the command, Terraform will first generate and show you the same execution apply you just reviewed with terraform apply (this is a crucial, final safety check). Then it will then prompt you to confirm that you want to proceed. You will need to type yes and press Enter.

Once you approve, Terraform will connect to your Azure subscription and begin creating all the resources in the correct order (e.g., the Resource Group first, then the VNet, then the AKS cluster just as an example). You will see live output in your terminal as each resource is created. A successful "Apply complete!" message means your sandbox environment is built and ready for use.


### Lab Objective

Execute the approved `terraform apply` and provision your live Azure infrastructure. You will use the terraform apply command to build all the resources that you create in your `.tf` files like an Azure Kubernetes Service (AKS) cluster) defined in your configuration. This step transitions your infrastructure from code into a real, running sandbox environment *in your Azure subscription.*

### Procedure

1. Change into the *aks* directory where we will be doing the work for the Azure labs.

    `student@bchd:~$` `cd ~/clearml-aws/terraform/clearml-aks`

0. **WAIT WAIT**. This next step is where you start burning the bills. It creates the actual infrastructure up in your Azure tenant. 

0. Run the terraform apply command. **You need to be logged into your cloud provider for this to function.**

    `student@bchd:~/clearml-aws/terraform/clearml-aks$` `terraform apply`

    > **If you want to start being charged** and create all the resources, when prompted type "yes" and then hit Enter.

0. This also will create the state file, *terraform.tfstate* which is a JSON file you can take a look at if you wish.

    `student@bchd:~/clearml-aws/terraform/clearml-aks$` `view terraform.tfstate`

    > After using your arrow keys to scroll through, `:q` to quit

**NOTE**: Next, you may have to install specific software locally  in order to run commands against your cluster up in your Azure cloud space.
