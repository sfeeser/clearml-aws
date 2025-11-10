# Install Local Software

Before we can build our cloud infrastructure (Infrastructure as Code), we must set up our local workstation with the necessary command-line tools. These tools are the "construction equipment" we'll use to build, manage, and communicate with our cloud environment.

### Lab Objective

The objective of this lab is to install the five core tools we need: Terraform (the builder), the AWS CLI (the cloud communicator), kubectl (the cluster remote control), Helm (the cluster app-store), and jq (the data utility).

### Procedure

1. Install Terraform This is our "builder." It reads our code and builds the infrastructure. We'll add its official apt repository to install it.

   `student@bchd:~$` `curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg student@bchd:~$ echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list`

0. Update and install terraform

    `student@bchd:~$` `sudo apt update && sudo apt install terraform -y`

0. Install AWS CLI (v2) This is our "cloud communicator." It allows our local machine to authenticate with our AWS account. We'll download and run the official AWS installer.

    `student@bchd:~$ curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" student@bchd:~$ unzip awscliv2.zip`

0. Run the aws install script

    `student@bchd:~$` `sudo ./aws/install`

0. Install kubectl This is our "cluster remote control." It lets us send commands to our Kubernetes cluster after it's built.

    `student@bchd:~$` `curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"`

0. Make the program executable and available to you command line.

   `student@bchd:~$` `chmod +x kubectl`

   `student@bchd:~$` `sudo mv kubectl /usr/local/bin/`

0. Install helm This is our "cluster app-store." It's a package manager that simplifies installing complex applications like ClearML.

    `student@bchd:~$` `curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash`

0. Install jq This is a "data utility" that helps us parse and read the JSON data that AWS and Kubernetes send back. It's essential for debugging.

    `student@bchd:~$` `sudo apt update && sudo apt install jq -y`
