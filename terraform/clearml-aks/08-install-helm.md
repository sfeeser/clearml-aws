# Installing Helm and Adding a Chart Repository

Helm is a package manager for Kubernetes. Think of it like apt or dnf for your Kubernetes cluster. Instead of installing complex applications (like ClearML) with dozens of manual kubectl commands, Helm lets you install, upgrade, and manage them as a single package called a "Chart."

### Lab Objective

The objective of this lab is to install the Helm client and add the official ClearML "Chart" repository. This will prepare your environment to deploy the ClearML application to your AKS cluster in the next lab.

### Procedure

1. Install Helm. This  downloads and runs an official script from the Helm GitHub repository. The script automatically detects your operating system (Linux) and installs the helm program into /usr/local/bin, making it available everywhere. 

    `student@bchd:~$` `curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash`

0. Add the ClearML Helm Repository. This tells Helm about a new "software source." It gives the short name clearml to the chart repository located at the specified URL. Helm now knows where to look when you ask for a ClearML chart. 

    `student@bchd:~$` `helm repo add clearml https://clearml.github.io/helm-charts`

0. Update Your Helm Repositories. Here helm fetches the latest list of all charts from all repositories you've added (including the clearml one). This is just like running sudo apt update to refresh your system's package lists. 

    `student@bchd:~$` `helm repo update`

0. Verify the Chart is Available. Helm searches all your configured repositories for any chart with "clearml" in its name. This is a final check to confirm Helm added the repo correctly and can find the packages we need for the next step. 

    `student@bchd:~$` `helm search repo clearml`
