**Great!** The cluster is up — now let’s **get you connected** with `kubectl` and your kubeconfig.

---

### Step 1: Install `kubectl`

```bash
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
sudo mv kubectl /usr/local/bin/
```

Verify:
```bash
kubectl version --client
```

---

### Step 2: Export Kubeconfig (Fix the Path)

You ran:
```bash
terraform output -raw kubeconfig > ~/.kube/clearml-dev.config
```

But got:
```
-bash: /home/sfeeser/.kube/clearml-dev.config: No such file or directory
```

→ This means `~/.kube/` **doesn’t exist yet**.

**Fix**:
```bash
mkdir -p ~/.kube
terraform output -raw kubeconfig > ~/.kube/clearml-dev.config
```

---

### Step 3: Test Cluster Access

```bash
kubectl --kubeconfig ~/.kube/clearml-dev.config get nodes -o wide
```

**Expected output**:
```
NAME                                   STATUS   ROLES   AGE   VERSION   INTERNAL-IP   EXTERNAL-IP   OS-IMAGE             KERNEL-VERSION      CONTAINER-RUNTIME
aks-default-XXXXXX-vmss000000          Ready    agent   3m    v1.32.x   10.0.1.4      <none>        Ubuntu 22.04.x LTS   x.x.x-azure         containerd://x.x.x
aks-default-XXXXXX-vmss000001          Ready    agent   3m    v1.32.x   10.0.1.5      <none>        Ubuntu 22.04.x LTS   x.x.x-azure         containerd://x.x.x
```

---

### Step 4: (Optional) Set Default Kubeconfig

```bash
export KUBECONFIG=~/.kube/clearml-dev.config
echo 'export KUBECONFIG=~/.kube/clearml-dev.config' >> ~/.bashrc
```

Now just run:
```bash
kubectl get nodes
```

---

### You’re In!

```bash
kubectl get pods --all-namespaces
```

→ Shows system pods running.

---

### Next: Deploy ClearML

```bash
# Install Helm
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# Add repo
helm repo add clearml https://clearml.github.io/helm-charts
helm repo update

# Install (dev mode)
helm install clearml-dev clearml/clearml \
  --namespace clearml --create-namespace \
  --set global.ingress.enabled=true \
  --set global.ingress.host=clearml-dev.$(terraform output -raw resource_group).nip.io
```

Get the IP:
```bash
kubectl get svc -n clearml clearml-dev-clearml-webserver -o jsonpath='{.status.loadBalancer.ingress[0].ip}'
```

Open in browser: `http://<IP>` → **ClearML is live!**

---

Run the `mkdir` + `terraform output` line **now** — you’ll be in the cluster in 30 seconds.
