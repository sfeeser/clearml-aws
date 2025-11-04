### Module Overview: The Managed Controller Node

The `eks/` module provisions the **Kubernetes Control Plane (EKS)**. In your private cloud, this is the highly-available, secure **Master/Controller Node** running the API server, scheduler, and etcd.

In AWS, this is a **fully managed service**. This module simply creates the necessary identity and network pointers for AWS to deploy and maintain it in the private subnets we defined.

### Racker and Stacker Translation

| On-Premises Component | EKS (AWS) Component | Purpose |
| :--- | :--- | :--- |
| **Controller Node(s)** | **AWS EKS Control Plane** | Managed by AWS for high availability, hidden from user access. |
| **Controller Node OS Role** | **`aws_iam_role.cluster`** | The AWS identity that the EKS Control Plane uses to manage networking resources (like ENIs) in your VPC. |
| **Controller Node IP** | **`cluster_endpoint`** (Output) | The unique, secure network address for your `kubectl` commands. |
| **Self-Signed CA** | **`cluster_certificate_authority_data`** (Output) | The public key needed to secure the TLS handshake when connecting to the `cluster_endpoint`. |

### The Central Security Contract: OIDC Trust

The most critical output is the **OIDC Issuer**. This concept replaces the traditional method of placing AWS Access Keys inside your containers.

* **Traditional:** You would hardcode an IAM user's credentials into your deployment, which is a security risk.
* **Cloud-Native (IRSA):** The EKS cluster acts as a trusted **Identity Provider**. The OIDC Issuer URL allows Kubernetes to mint a short-lived security token for your ClearML pods.
* **Workflow:** The **ClearML Pod (Service Account)** gets a token $\rightarrow$ The pod presents this token to **AWS IAM** $\rightarrow$ AWS uses the **OIDC Issuer** to verify the token's signature $\rightarrow$ AWS grants the pod temporary access to S3.

The **`oidc_issuer`** output is the address of this digital ID authority, which is consumed directly by the next module, **`irsa/`**.

### Module Files and Functions

| File | Function | Key Components |
| :--- | :--- | :--- |
| **`main.tf`** | **Deployment Blueprint** | Defines `aws_eks_cluster`, `aws_iam_role.cluster`, and uses the `null_resource` to execute the local `aws eks update-kubeconfig` command, creating the connection file. |
| **`variables.tf`**| **Module Inputs** | Requires the network addresses (`private_subnets`) and the cluster version. |
| **`outputs.tf`** | **Connectivity Hand-off**| Provides all necessary connection details (endpoint, CA data, OIDC issuer) to downstream processes (Ansible, IRSA module). |

