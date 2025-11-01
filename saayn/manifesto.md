# SAAYN Manifesto  
**Specifications Are All You Need**

### 1. Purpose

SAAYN defines a methodology for building complete, deterministic systems through **semantic specifications**.  
It replaces informal “vibe coding” with formal intent, ensuring that all artifacts — code, docs, and deployments — are generated from semantically pure exemplars.

The goal of SAAYN is not to remove creativity but to **channel it** into the highest layer of expression: *intent*.

### 2. Core Principle

> “If you can describe it semantically, you can regenerate it deterministically.”

Every repository that follows SAAYN must be **self-describing**, containing the human rationale, exemplars, and artifacts necessary to rebuild itself — from scratch — without ambiguity or hidden state.


### 3. The Three Semantic Layers

| Layer | Description | Artifact Relationship |
|--------|--------------|------------------------|
| **Intent** | The *why*: human-readable purpose and rationale. | Shapes exemplars; may include commentary, constraints, or policy. |
| **Exemplar** | The *what*: structured, semantically pure description of what must exist. | Source material for all generated artifacts. |
| **Artifact** | The *how*: executable outputs synthesized from one or more exemplars. | Must trace lineage directly to exemplars. |

#### 3.1 Creativity boundary

AI and human authors are free to create new exemplars when intent is present but no exemplar yet exists.  
However, once an exemplar is defined, all derived artifacts must be **deterministically regenerable** from it.

### 4. Deterministic Regeneration

A SAAYN-compliant system can be torn down and rebuilt without loss of meaning:

```bash
make regenerate
# → reads specbooks → emits packfiles/tarballs → rebuilds repo
````

* **Repeatability:** Same inputs, same outputs, every time.
* **Auditability:** Every file’s provenance is recorded through its exemplar.
* **Replaceability:** Any artifact may be deleted and re-emitted from the spec.

Artifacts are *ephemeral*. Exemplars are *eternal*.

### 5. Repository Topology (SAAYN Context)

Each project must include a top-level `saayn/` directory containing all semantic sources.

Example:

```
project-root/
├─ saayn/
│  ├─ manifesto.md          # This file
│  ├─ manifest.yaml         # Declares specbooks and packaging rules
│  ├─ specbook-terraform.md # Infrastructure layer
│  └─ specbook-ansible.md   # Configuration layer
├─ terraform/
├─ ansible/
└─ spec/
```

The presence of `saayn/` distinguishes a SAAYN-compliant repo from an ordinary codebase.

### 6. SpecBooks

A **SpecBook** is the minimal self-contained document that bridges the three layers:

1. States *Intent* for its domain (e.g., infrastructure, application, automation).
2. Declares *Exemplars* (directory structures, schemas, YAML, or file templates).
3. Defines how to produce *Artifacts* (packfiles, tarballs, or verified code).

Each SpecBook exists independently, so multiple SpecBooks may coexist for different domains.

Example:

* `specbook-terraform.md` — Infrastructure foundation
* `specbook-ansible.md` — Application configuration

### 7. Packaging Specification

SAAYN recognizes two canonical artifact packaging methods:

| Format       | Description                                                                  |
| ------------ | ---------------------------------------------------------------------------- |
| **TAR**      | Binary archive (`.tar.gz`) containing emitted directories and files.         |
| **PACKFILE** | Text-only representation where each file is delimited by `@@@FILE … @@@END`. |

All packfiles are *deterministic* and can be materialized with a short script.
Each SpecBook must describe its packaging format explicitly.

### 8. SAAYN Workflow

1. **Write SpecBooks** — capture intent, exemplars, and artifact rules.
2. **Emit Artifacts** — AI or compiler synthesizes Terraform, Ansible, code, or docs.
3. **Materialize Repo** — packfile or tar is untarred/applied into directories.
4. **Run & Verify** — ensure behavior matches intent.
5. **Destroy & Rebuild** — confirm deterministic regeneration.

The cycle is both **creative** and **scientific** — design intent once, regenerate forever.

### 9. Collaboration Model

* **Humans** express intent and curate exemplars.
* **AI agents** translate exemplars into artifacts.
* **Version control** tracks both the semantic (spec) and the material (artifact) layers.
* **Diffs** between exemplars are *semantic changes*, while diffs between artifacts are *renderings*.

When conflicts occur, exemplar truth wins.

### 10. Creativity Clause

SAAYN does not suppress creativity — it protects it.

> If an AI or human needs to create something entirely new and no exemplar exists, it must emit a new exemplar at the same semantic level, not a silent artifact.

All spontaneous outputs must declare themselves as *exemplar proposals* until validated by human review.

### 11. Teaching Philosophy

SAAYN was developed to make teaching infrastructure, automation, and AI reproducible.
Each SpecBook doubles as:

* A **lesson plan** (for instructors).
* A **blueprint** (for systems).
* A **validation harness** (for AI or automation tools).

By separating *intent*, *exemplar*, and *artifact*, SAAYN allows both humans and AIs to collaborate without confusion about authorship or authority.

### 12. Manifest and Provenance

Every SAAYN directory should include a `manifest.yaml` describing:

* Project name, version, and maintainers.
* Each SpecBook’s domain and artifact target.
* Output packaging type (tar or packfile).
* Hashes of generated artifacts (optional).

Provenance must be human-verifiable and machine-parsable.

> **SAAYN is not a tool. It’s a discipline.**
> It teaches that the path from idea to running system is not magic — it’s semantics.
