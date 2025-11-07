# Access Azure

### Objective

`student@bchd:~$` ``

### Procedure

1. Set your environment variables (azure keys in bitwarden)

0. clone the repo

    `student@bchd:~$` `https://github.com/sfeeser/clearml-aws.git`

    `student@bchd:~$` `cd clearml-aws/terraform/clearml-aks/`

0. Install the azure cli to login.

    `student@bchd:~$` `curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash`

0. Log in. 

    `student@bchd:~$` `az login`

0. Take a look at your account

    `student@bchd:~$` `az account show`

0. check options for resources

   `student@bchd:~$` `az account list --output table`

   `student@bchd:~$` `az vm list-skus --location eastus --all   --output table`

0. Init terraform
    `student@bchd:~$` `terraform init`

    `student@bchd:~$` `terraform validate`

    `student@bchd:~$` `terraform plan`

    `student@bchd:~$` `terraform apply`

    `student@bchd:~$` `terraform destroy`



0. Install kubernetes

    `student@bchd:~$` `curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"`

0. Make kubectl executable

    `student@bchd:~$` `chmod +x kubectl`

0. Setup a kube config destination folder

    `student@bchd:~$` `mkdir -p ~/.kube`

0. Run get nodes using the specified config (won't work yet)

    `student@bchd:~$` `kubectl --kubeconfig ~/.kube/clearml-dev.config get nodes -o wide`

0. output the terraform kube config to the local kube dir.

    `student@bchd:~$` `terraform output -raw kubeconfig > ~/.kube/clearml-dev.config`

0. Test cluster access

    `student@bchd:~$` `kubectl --kubeconfig ~/.kube/clearml-dev.config get nodes -o wide`

0. move kubectl to default path for continued use.

    `student@bchd:~$` `sudo mv kubectl /usr/local/bin/`

kubectl version --client
kubectl get nodes
terraform output -raw kubeconfig > ~/.kube/clearml-dev.config
mkdir -p ~/.kube
terraform output -raw kubeconfig > ~/.kube/clearml-dev.config
kubectl --kubeconfig ~/.kube/clearml-dev.config get nodes -o wide
kubectl get nodes
export KUBECONFIG=~/.kube/clearml-dev.config
echo 'export KUBECONFIG=~/.kube/clearml-dev.config' >> ~/.bashrc
kubectl get nodes
kubectl get pods --all-namespaces
# Install Helm
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
# Add repo
helm repo add clearml https://clearml.github.io/helm-charts
helm repo update
# Install (dev mode)
helm install clearml-dev clearml/clearml   --namespace clearml --create-namespace   --set global.ingress.enabled=true   --set global.ingress.host=clearml-dev.$(terraform output -raw resource_group).nip.io
history
kubectl get svc -n clearml clearml-dev-clearml-webserver -o jsonpath='{.status.loadBalancer.ingress[0].ip}'
