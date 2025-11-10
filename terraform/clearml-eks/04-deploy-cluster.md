# Deploy the Cluster

This is the moment. All the preparation is done. You are now ready to run the two commands that build your entire cloud environment. You will first initialize Terraform and then apply the plan.

### Lab Objective

You will initialize Terraform to connect to your S3 backend and then run terraform apply to build the EKS cluster and all its supporting resources.

### Procedure

1. Initialize Terraform This command reads your backend.tf, connects to your S3 bucket (which is why you must have run aws configure), and downloads all the necessary AWS provider plugins. **Reminder**: you must be in the correct directory.

    `student@bchd:~$` `terraform init`

0. This step is technically optional ***BUT*** we do not recommend skipping. This step basically gives you a dry run of the concourse to come.

    `student@bchd:~$` `terraform plan`

0. The next step will start charing you money!!! Be sure everything you want is set up correctly.

0. Apply the Plan This command will show you a plan of all resources to be created. After you type yes, it will build the entire EKS cluster. This can take 15-20 minutes.

    `student@bchd:~$` `terraform apply`

    > REMINDER: THIS COSTS YOU MONEY $$$. Use `terraform destroy` and type yes and hit Enter at the prompt if you need!!!

0. Scroll up and down if needed to review the plan, then type 'yes' and press Enter when prompted
