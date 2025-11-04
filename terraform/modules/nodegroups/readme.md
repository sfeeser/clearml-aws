## 📄 Nodegroups Module Documentation


http://googleusercontent.com/immersive_entry_chip/0

### Module Overview: The Worker Servers

The `nodegroups/` module is responsible for deploying and managing the **Worker Servers (EC2 instances)** that will run your Kubernetes workloads.

This module is the direct equivalent of configuring your automated provisioning system to rack up new server hardware, install the OS, and ensure the networking is configured so the servers can securely join the central **Controller Node (EKS Control Plane)**.

### Key Concept: IAM Node Role (The Machine's ID Badge)

On-premises, a system administrator gives a server credentials or network access based on its physical location or hostname. In AWS, every worker machine needs a digital identity via an **IAM Role**.

* **Role Definition:** The `aws_iam_role.node_group_role` is the permanent identity assigned to every EC2 instance in the Node Group.
* **Permissions:** This role includes policies that are necessary for the worker to function:
    * **Talk to EKS:** Allows the machine to register itself with the EKS Control Plane.
    * **Network:** Allows the machine to manage its network interfaces (CNI).
    * **Container Access:** Allows the machine to pull container images from AWS registries (ECR).

Without this specific IAM role, the new servers would boot up in the private subnet but would not be trusted by EKS and could not join the cluster. 

### Module Files and Functions

| File | Function | Racker/Stacker Analogy |
| :--- | :--- | :--- |
| **`main.tf`** | **Deployment Blueprint** | Defines the IAM Role (the Identity), attaches the required policies (the Permissions), and creates the `aws_eks_node_group` (the Server Scaling Group). |
| **`variables.tf`**| **Module Inputs (BOM)** | Takes inputs like the `cluster_name`, `subnet_ids`, and the specific `nodegroup_definitions` (e.g., instance size, disk size, min/max count) from the `spec/config.yaml`. |
| **`outputs.tf`** | **The Hand-off** | Exports the names/IDs of the newly created Node Groups. |

