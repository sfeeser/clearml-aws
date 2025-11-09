# Install Kubectl and Check Pods!

Previously, `terraform apply` was called to build an Azure Kubernetes Service (AKS) cluster. This cluster is a complex system running on servers in an Azure data center, ready to build and run your applications. Now that your cluster is built, we need a way to communicate with it from our local machine. *We are not installing Kubernetes* - we've already done that in Azure. Instead we are installing kubectl. 

Think of kubectl as the remote control for your Kubernetes cluster. It's a small command-line tool that sends your Kubernetes commands securely over the internet to your AKS cluster's API.

To make this work, kubectl needs a configuration file (called a "kubeconfig") that acts as the "pairing" information. This file tells your remote control the specific address of your cluster and provides the security keys to log in.

### Lab Objective

The objective of this lab is to configure your local workstation (bchd) to securely connect to and interact with the new AKS cluster you provisioned with Terraform.

By the end of this lab, you will have:

- Installed the kubectl client (the "remote control").

- Extracted the kubeconfig (the "access keys") from your Terraform state.

- Configured your shell environment to use these credentials automatically.

- Verified a successful connection by listing the nodes of your cluster.

### Procedures

1. Download the kubectl program binary. The inner $(curl ...) command finds the latest stable version number, and the outer curl command downloads the corresponding file for a 64-bit Linux system.

    `student@bchd:~$` `curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"`

0. Make kubectl Executable. Since downloaded files don't have permission to run as a program, use `chmod +x` ("change mode to executable") grants this permission.

    `student@bchd:~$` `chmod +x kubectl`

0. Move kubectl to a Default Path. We use sudo to move the kubectl file into /usr/local/bin/. This directory is part of your system's PATH, which means you can now run the kubectl command from any directory in your terminal.

    `student@bchd:~$` `sudo mv kubectl /usr/local/bin/`

0. Check kubectl Client Version. This shows the version of the kubectl client you just installed. It's a good way to verify your installation without needing to connect to the cluster.

    `student@bchd:~$` `kubectl version --client`

0. Set up a Kubeconfig Destination Folder. By default, kubectl looks for its configuration files in a hidden folder in your home directory (~) named .kube. We make that directory.

    `student@bchd:~$` `mkdir -p ~/.kube`

0. Run get nodes (This Will Fail). This is a deliberate test to show what's missing. We're telling kubectl to use a specific config file (clearml-dev.config) that we haven't created yet. It will fail with an error, proving that the config file is required.

    `student@bchd:~$` `kubectl --kubeconfig ~/.kube/clearml-dev.config get nodes`

0. Output the Terraform Kubeconfig to "pair" your remote control.

    `student@bchd:~$` `terraform output -raw kubeconfig > ~/.kube/clearml-dev.config`

    <!--This is the key step. terraform output kubeconfig retrieves the kubeconfig value from your terraform.tfstate file (which you defined in outputs.tf). The -raw flag removes extra quotes, and the > (redirect) symbol saves that raw text directly into the clearml-dev.config file. You have now "paired" your remote control.
    -->

0. Test Cluster Access (This Should Succeed). We run the exact same command from before but just with a *-o wide* for the output since we assume this will work now. This time, kubectl finds the file, reads the credentials, successfully connects to your AKS cluster, and prints a list of your worker nodes.

    `student@bchd:~$` `kubectl --kubeconfig ~/.kube/clearml-dev.config get nodes -o wide`

0. Set Your KUBECONFIG Variable. First, we'll set for current session. 

    `student@bchd:~$` `export KUBECONFIG=~/.kube/clearml-dev.config`

0. Now we will make the variable permanent for future sessions.

    `student@bchd:~$` `echo 'export KUBECONFIG=~/.kube/clearml-dev.config' >> ~/.bashrc`

0. Now load that variable for the current session.

    `student@bchd:~$` `source ~/.bashrc`

    > Typing --kubeconfig every time is tedious. This set of three commands tell your shell to use a specific config as the default config file. Export sets it for your current terminal, and echo  >> ~/.bashrc adds it to your shell's startup script to make it permanent for all future terminals. source ~/.bashrc reloads that startup file so the change takes effect immediately.

0. Now Get Your Nodes in a much easier way. Because the KUBECONFIG variable is now set, you can run kubectl commands without specifying the --kubeconfig flag.

    `student@bchd:~$` `kubectl get nodes`

0. Check Your Pods!!! This is your first "real" command to inspect the cluster. It asks Kubernetes to show all the running "pods" (which are groups of containers) in all system "namespaces." This shows you the core components of Kubernetes, like the cluster's DNS server (coredns) and network controllers.

    `student@bchd:~$` `kubectl get pods --all-namespaces`
