# Installing ClearML with Helm

Helm is a package manager for Kubernetes. Think of it like apt or dnf for your Kubernetes cluster. Instead of installing complex applications (like ClearML) with dozens of manual kubectl commands, Helm lets you install, upgrade, and manage them as a single package called a "Chart."

### Lab Objective
The objective of this lab is to use Helm to deploy the complete ClearML application stack (servers, databases, etc.) into your AKS cluster. You will use a single Helm command to provision the application and then monitor its startup progress to find its public IP address.

### Procedure

1. Install ClearML (dev mode). Helm will install a new application.

    `student@bchd:~$` `helm install clearml-dev clearml/clearml --namespace clearml --create-namespace --set global.ingress.enabled=true --set global.ingress.host=clearml-dev.$(terraform output -raw resource_group).nip.io`

    > clearml-dev: This is your personal "release name" for this installation.

    > clearml/clearml: This is the chart (package) to install from the repository we added.

    > --namespace clearml --create-namespace: This installs the app in its own "folder" (namespace) and creates it if it doesn't exist.

    > --set ...: This overrides default settings. We are enabling the ingress (the web entry point) and setting its host (URL). The URL is built dynamically using your Terraform resource group name to make it unique. 


0. Watch the Application Start (Validation) The helm install command finishes quickly, but the application (databases, web servers) takes a few minutes to start. This command lets you "watch" (-w) all the pods (application containers) in the clearml namespace as they are created and become "Running". 

    `student@bchd:~$` `kubectl get pods -n clearml -w`

    > Note: Wait until all the main pods (apiserver, webserver, mongodb, etc.) are in a "Running" or "Completed" state. Press Ctrl+C to exit the watch.

0. Check on the running service This command retrieves the public IP address for the ClearML webserver. The Helm chart creates a Kubernetes "Service" of type LoadBalancer, which tells Azure to provision and assign a public IP. This jsonpath query digs into the service's details and prints only that IP address.

    `student@bchd:~$` `kubectl get svc -n clearml clearml-dev-clearml-webserver -o jsonpath='{.status.loadBalancer.ingress[0].ip}'`

0. Verify Service Status (Validation) This command provides a more human-readable view of all the services in the clearml namespace. You can use this to see the public IP (listed under the EXTERNAL-IP column) for the clearml-dev-clearml-webserver and verify that it's ready to accept traffic.

    `student@bchd:~$` `kubectl get svc -n clearml`

