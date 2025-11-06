This is designed to supplement the README lab by giving details installation and confirmation instructions for pre-requisites, tailored for **Ubuntu 24.04**.


## 🛠️ Prerequisites: Installation and Verification Commands

### 1\. Helper Utilities (`make` and `jq`)

These are small, standard tools available in Ubuntu's main repository.

**To Install:**

```bash
sudo apt update
sudo apt install -y make jq
```

**To Verify:**

```bash
make --version
jq --version
```

-----

### 2\. Ansible (2.16+)

We'll use the official PPA (Personal Package Archive) for Ansible to ensure you get a modern version.

**To Install:**

```bash
# Add the official Ansible PPA
sudo apt install -y software-properties-common
sudo add-apt-repository --yes --update ppa:ansible/ansible

# Install Ansible
sudo apt install -y ansible
```

**To Verify:**

```bash
ansible --version
# This should show a version well above 2.16
```

-----

### 3\. AWS CLI (v2)

The version in `apt` is often old. The official method is to download the bundle.

**To Install:**

```bash
# Download the installer
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"

# Unzip it (you may need to 'sudo apt install -y unzip' if you don't have it)
unzip awscliv2.zip

# Run the installer
sudo ./aws/install
```

**To Verify:**

```bash
aws --version
# Look for 'aws-cli/2.'
```

-----

### 4\. Terraform (1.7+)

We'll add the official HashiCorp (the makers of Terraform) repository.

**To Install:**

```bash
# Add the HashiCorp GPG key
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg

# Add the official repository
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list

# Update and install
sudo apt update
sudo apt install -y terraform
```

**To Verify:**

```bash
terraform --version
# This should show 1.7 or newer
```

-----

### 5\. `kubectl` and `helm` (Kubernetes Tools)

These are best installed directly from their official sources.

#### `kubectl`

**To Install:**

```bash
# Download the latest stable version
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"

# Make it executable and move it to your path
chmod +x ./kubectl
sudo mv ./kubectl /usr/local/bin/kubectl
```

**To Verify:**

```bash
kubectl version --client
```

#### `helm`

**To Install:**

```bash
# Download and run the official install script
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh
```

**To Verify:**

```bash
helm version
# This should show v3
```

-----

## 👉 Your Next Steps

After you've installed all of the above, you can continue with the lab instructions:

1.  **Run the `ansible-galaxy` command** from your lab's Step 2:

    ```bash
    ansible-galaxy collection install kubernetes.core community.kubernetes
    ```

2.  **Continue to Step 3 (`aws configure`)**. This is where you will use the **Access Keys** you saw in your AWS portal. When it prompts you for:

      * **AWS Access Key ID:** [Paste the key from your portal]
      * **AWS Secret Access Key:** [Paste the secret from your portal]
      * **Default region name:** `us-east-1` (or whatever `spec/config.yaml` will use)
      * **Default output format:** `json`

You should be all set to continue the lab from there.
