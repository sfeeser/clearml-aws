# One-Time AWS Setup

Terraform needs two things to work: a "user" to act on its behalf (the iac-runner) and a "place" to store its memory, or "state" (the S3 bucket). This state file is how Terraform remembers what it has built. We'll create both of these manually in the AWS console.

### Lab Objective

You will manually create the S3 bucket for the Terraform backend and the iac-runner IAM user that has administrative permissions for the sandbox.

### Procedure

1. Log in to your AWS Console Use your normal sandbox admin user to log in to the AWS web console.

0. Create the S3 State Bucket

0. Go to the S3 service.

0. Click "Create bucket".

    - Bucket name: Give it a globally unique name (e.g., my-company-clearml-tfstate-20251107).

    - Region: Select us-east-1 (N. Virginia).

    - Block all public access: Keep this checked.

0. Click "Create bucket".

    > Important: Write this bucket name down. You will need it in Phase 3.

0. Create the iac_runner IAM User

0. Go to the IAM service.

0. Click "Users" in the left-hand menu, then "Create user".

    - User name: iac-runner

    - Click Next.

    - Select "Attach policies directly".

0. In the search box, find and check the box for AdministratorAccess.

    > Note: For a real production setup, you'd create a custom policy with fewer permissions. For a sandbox, AdministratorAccess is the simplest way to guarantee it works.

0. Click Next, then "Create user".

0. Get Your Keys

0. Click on the iac-runner username you just created.

0. Click the "Security credentials" tab.

0. Scroll down to "Access keys" and click "Create access key".

0. Select "Command Line Interface (CLI)".

0. Check the "I understand" box and click Next.

0. Click "Create access key".

0. CRITICAL STEP: Copy the Access key ID and Secret access key into a secure notepad. You will never see the secret key again.

0. Configure Your Local AWS CLI This final step "gives" the iac-runner keys to your local terminal, allowing your AWS CLI tool to authenticate.

    `student@bchd:~$` `aws configure AWS Access Key ID [None]: <PASTE_YOUR_IAC-RUNNER_ACCESS_KEY_ID> AWS Secret Access Key [None]: <PASTE_YOUR_IAC-RUNNER_SECRET_KEY> Default region name [None]: us-east-1 Default output format [None]: json`
