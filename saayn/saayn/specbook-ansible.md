## `saayn/specbook-ansible.md`

```markdown
# SpecBook: ClearML Enterprise Deployment (Configuration Layer)
Version: draft-01  
Author: Stuart Feeser (Alta3 Research)  
Layer: Configuration / Application  
SAAYN Domain: Ansible (+ Helm, kubectl)

---

## 1. Intent

This SpecBook defines the **in-cluster configuration** required to deploy ClearML Enterprise
on the EKS cluster provisioned by the Terraform layer.

**Control separation doctrine**

- Terraform owns cloud resources (VPC, EKS, nodegroups, IAM/IRSA, S3, ACM, Route53).
- Ansible owns **only** Kubernetes resources and runtime configuration (namespaces, Helm releases, ConfigMaps, Secrets, Jobs).
- Ansible **must not** create/modify/destroy any AWS resource managed by Terraform.
- Teardown sequence: **Ansible uninstall** (namespace/Helm) → **Terraform destroy**.

**Outcomes**

- A working ClearML control plane reachable via the cluster Service (ingress optional).
- A smoke test that logs an experiment and uploads an artifact to S3.
- All values are sourced from `spec/config.yaml` + Terraform outputs.

---

## 2. Exemplar

### 2.1 Directory Topology (produced by this SpecBook)

```

ansible/
├─ README.md
├─ playbooks/
│  └─ site.yml
├─ roles/
│  └─ clearml/
│     ├─ tasks/main.yml
│     ├─ templates/values.yaml.j2
│     └─ vars/main.yml
└─ inventories/
└─ example/hosts.yml

````

> Note: The `spec/config.yaml` file is shared with the Terraform layer and **already exists at repo root**.
> Ansible will read it as a vars-file.

### 2.2 Inputs (contracts)

- **Terraform outputs** from the infra layer:
  - `kubeconfig_path` (string) — path to kubeconfig for the EKS cluster
  - `s3_artifacts`, `s3_datasets`, `s3_logs` (strings/ARNs) — names/ARNs to reference
  - Optional `certificate_arn` if DNS/TLS is provisioned (not used directly by Ansible)
- **Config file**: `spec/config.yaml`, minimally with:
  - `aws.region`, `s3.*`
  - `ansible.namespace` (default `clearml`)
  - Optional: `aws.dns_tls.*` if ingress will be demonstrated

### 2.3 Role responsibilities

`roles/clearml` must:

1. **Create namespace** (idempotent)
2. **Render Helm values** from `templates/values.yaml.j2` using:
   - `spec/config.yaml`
   - environment or file containing Terraform outputs
3. **Install ClearML chart** (api, web, files) using `community.kubernetes.helm`
4. **Run smoke test**:
   - Wait for `web` and `api` readiness
   - `curl` API `/status` == OK
   - Optional Python SDK snippet to log one task + upload one file to S3
5. **Uninstall path**:
   - Helm uninstall or delete namespace

---

## 3. Artifact

### 3.1 Artifact type

- **Artifact:** Packfile or TAR (declared in `saayn/manifest.yaml`)
- **Output Name:** `clearml-aws-ansible-v1.pack` or `.tar.gz`
- **Root Directory:** `ansible/`

### 3.2 File Composition Rules

- All YAML must parse with `ansible-lint` defaults (or `--exclude` if justified).
- `site.yml` must be runnable directly on a machine with kubectl context set to `kubeconfig_path`.
- No tasks may invoke AWS APIs that mutate infra state (e.g., creating buckets, roles, ALBs).

---

## 4. Execution Semantics

### 4.1 Variables and input wiring

Ansible must support **two** ways to access Terraform outputs:

1. **Environment-driven** (simple for demos)
   - Export `KUBECONFIG` to the value of Terraform `kubeconfig_path`.
   - Export `TF_OUT_JSON` path to a `terraform output -json` dump (optional).

2. **File-driven**
   - A helper step (outside this SpecBook) writes a small YAML file, e.g.:
     ```yaml
     kubeconfig_path: /path/to/kubeconfig
     s3_artifacts_bucket: clearml-demo-artifacts
     s3_datasets_bucket: clearml-demo-datasets
     s3_logs_bucket: clearml-demo-logs
     ```
   - `site.yml` loads it via `vars_files`.

### 4.2 Playbook contract (`playbooks/site.yml`)

- The play targets `localhost` with `connection: local`.
- It **includes** role `clearml`.
- It reads `spec/config.yaml` as one of its `vars_files`.

### 4.3 Role contract (`roles/clearml/tasks/main.yml`)

- **Create namespace** using `kubernetes.core.k8s` (state=present).
- **Render values.yaml** from `templates/values.yaml.j2`.
- **Helm install/upgrade** ClearML chart with `community.kubernetes.helm`:
  - `release_name: clearml`
  - `chart_ref: <clearml chart or repo>`
  - `values: "{{ lookup('file', rendered_values_path) | from_yaml }}"`
- **Wait for readiness** using `kubernetes.core.k8s_info` and retries.
- **Smoke tests**:
  - HTTP readiness on web and api
  - Optional Python SDK one-shot task + artifact upload
- **Uninstall** (when invoked explicitly): Helm uninstall or namespace delete

---

## 5. Determinism Requirements

- Running `site.yml` twice is idempotent (Helm upgrade if release exists).
- Namespace creation must be idempotent.
- The role must **never** create Kubernetes objects that conflict with Terraform-managed resources.
- Uninstall must remove only resources created by this role/release.

---

## 6. Validation Criteria

A SpecBook-compliant artifact passes if:

1. `ansible-playbook --syntax-check playbooks/site.yml` passes.
2. Helm release converges to Ready.
3. `curl https://<host>/api/status` returns success (or ClusterIP test if no ingress).
4. Optional: `python -c` SDK snippet prints “OK” after upload to S3.
5. Uninstall path removes the namespace or Helm release with no residual pods.

---

## 7. Reference templates (informative, not normative)

### 7.1 `playbooks/site.yml` (skeleton)

```yaml
---
- name: ClearML install (cluster configuration)
  hosts: localhost
  connection: local
  gather_facts: false

  vars_files:
    - ../../spec/config.yaml
    # - tf-outputs.yaml   # optional helper file

  vars:
    namespace: "{{ ansible.namespace | default('clearml') }}"
    kubeconfig_path: "{{ lookup('env','KUBECONFIG') | default(lookup('env','KUBECONFIG_PATH'), true) | default('~/.kube/config', true) }}"

  tasks:
    - name: Show target
      ansible.builtin.debug:
        msg: "Namespace={{ namespace }}, kubeconfig={{ kubeconfig_path }}"

    - name: Include ClearML role
      ansible.builtin.include_role:
        name: clearml
````

### 7.2 `roles/clearml/templates/values.yaml.j2` (example fields)

```yaml
ingress:
  enabled: {{ aws.dns_tls.enable | default(false) | tojson }}
  className: alb
  hosts:
    - "{{ aws.dns_tls.hostname }}.{{ aws.dns_tls.domain_name }}"
  tls:
    - secretName: clearml-tls
      hosts:
        - "{{ aws.dns_tls.hostname }}.{{ aws.dns_tls.domain_name }}"

storage:
  s3:
    artifactsBucket: "{{ s3.artifacts_bucket }}"
    datasetsBucket:  "{{ s3.datasets_bucket }}"
    logsBucket:      "{{ s3.logs_bucket }}"
```

> Note: exact ClearML chart keys may differ; adapt as needed in the Application SpecBook.

---

## 8. Relationship to Terraform SpecBook

This SpecBook **consumes** Terraform outputs but **does not** mutate Terraform-owned infrastructure.
If any new AWS primitive is required later (e.g., additional IRSA, buckets, or ALBs), it **must** be added to the Terraform SpecBook and re-provisioned there.

---

## 9. Provenance

* Author: Stuart Feeser
* Organization: Alta3 Research
* Spec lineage: SAAYN v1.0 — semantic purity (Intent → Exemplar → Artifact)
* Last modified: {{ now }}


[1]: https://github.com/sfeeser/clearml-aws.git "GitHub - sfeeser/clearml-aws"
