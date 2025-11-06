# Setting Up an AWS Organization and Sandbox Accounts for IaC

These instructions guide you through creating a secure AWS Organization with:
- A management account
- A sandbox member account
- Centralized login for users
- IaC (Infrastructure-as-Code) credentials for automation.

### Why Proper AWS Organization Setup Matters

Before diving into the setup, it’s important to understand *why* AWS Organizations and structured account management are essential, especially when deploying solutions like ClearML or any infrastructure-as-code (IaC) system.

When you first create an AWS account, it operates as a **standalone account**—with its own billing, identity, and access controls. This simple model works for individuals experimenting with AWS but quickly becomes problematic when scaling up. Mixing production workloads, test environments, and automation credentials inside one account leads to risks such as:

* Accidental deletion or modification of critical resources
* Runaway billing or unmonitored cost growth
* Difficulty isolating permissions and maintaining compliance

AWS solves these challenges through **AWS Organizations**, which let you centrally manage multiple accounts—each with strong isolation yet unified under one administrative and billing umbrella.

The first account you enable with AWS Organizations becomes your **management account**. Each additional account you create under it is a **member account**. Member accounts are independent AWS accounts governed through consolidated billing, central identity, and organization-wide policies.

This structure lets you:

* Isolate sandboxes, staging, and production environments
* Apply cost controls and budgets per account
* Centrally manage user identities via **IAM Identity Center (AWS SSO)**
* Enforce Service Control Policies (SCPs) and security baselines

For training and experimentation, this mirrors the structure used in enterprise cloud operations—providing both safety and realism.

### But I already have an AWS acount, now what?

If you already have a production AWS account, do **not** repurpose it as your management account. Instead, create a new management account as explained below which will serve as your administrative hub, and then link your existing production account as a **member account**.

Follow these steps:

1. **Create a new AWS account** by following the detailedf steps below. Now you will have a new account that will serve as your **management account**.
2. Return back to here after you do all the steps spelled out in the "How to Set Up an AWS Organization and Sandbox Account for IaC"
3. From the new management account, open **AWS Organizations** and choose **Create an organization → Enable all features.**
4. Once created, go to **Accounts → Add an account → Invite an existing AWS account.**
5. Enter the **email address** and **12-digit Account ID** of your existing production account.
   * AWS will send an invitation to that account.
6. Log in to your **production account**, open **AWS Organizations**, and accept the invitation.
7. Your production account now becomes a **member account**, governed and billed under the management account.
8. This approach ensures clean separation between administrative control (management account) and operational workloads (member accounts), aligning your setup with best practices for both production and sandbox environments.
9. Your old account will work exactly as it did before with one important exception, the billing will flow upwards to the managment account.

---

### Lab Steps - How to Set Up an AWS Organization and Sandbox Account for IaC

These instructions guide you through creating a secure AWS Organization with a management account, a sandbox member account, centralized login for users, and IaC (Infrastructure-as-Code) credentials for automation.

### 1. Create a Management Account and AWS Organization

1. Sign up for a new AWS account at [https://aws.amazon.com](https://aws.amazon.com).  
2. Once created, sign in as the **root user** (the email you used to register).  
3. Open the **AWS Organizations** service.  
4. Choose **Create an organization → Enable all features.**  
5. This account automatically becomes your **management account**.  
6. It will handle all billing, governance, and creation of sub-accounts (called **member accounts**).

### 2. Enable IAM Identity Center (AWS SSO)

1. From the management account, open **IAM Identity Center**.  
2. Click **Enable IAM Identity Center.**  
3. It will automatically connect to your AWS Organization.  
4. Go to **Settings → AWS access portal URL → Edit** and choose a custom subdomain, for example:

   ```
   https://yourcompany.awsapps.com/start
   ```

   This is the login portal everyone in your organization will use.

### 3. Add Users and Groups in IAM Identity Center

1. In **IAM Identity Center → Users**, click **Add user.**  
2. Enter name, email, and optional display name.  
3. Repeat for each person who should access AWS.  
4. *(Optional)* Create **Groups** such as `Admins`, `Developers`, or `Instructors`.  
5. In **Permission sets**, click **Create permission set**:  
   - Choose a template (e.g., `AdministratorAccess`) or create a custom one.  
   - Save it as something descriptive like **Org-Admin** or **Sandbox-User**.  
6. These users will receive setup emails and log in at your AWS Access Portal URL.

### 4. Create a Member (Sandbox) Account

1. In the management account, open **AWS Organizations → Accounts**.  
2. Click **Add an account → Create an AWS account.**  
3. Fill in:
   - **Account name:** something descriptive like `Sandbox-2025-01`  
   - **Email address:** a unique address not used by any other AWS account (e.g., `aws-sandbox+2025@yourdomain.com`)  
   - **IAM role name:** keep the default `OrganizationAccountAccessRole`
4. Add optional tags (recommended):  
   ```
   Project = Sandbox
   Environment = Training
   Owner = your.email@domain.com
   ExpirationDate = 2025-12-31
   ```
5. Click **Create account.**  
   AWS will provision the member account in a few minutes.

### 5. Assign Users to the Member Account

1. In **IAM Identity Center → AWS accounts**, select the new member account.  
2. Click **Assign users or groups.**  
3. Choose which users or groups should have access and assign a permission set (e.g., `AdministratorAccess` or `Sandbox-User`).  
4. Those users will now see this account tile in their AWS Access Portal dashboard.

### 6. Switch to the Member Account

From the management account console:

1. Click your account name (top-right) → **Switch role.**  
2. Enter:
   - **Account ID:** the 12-digit ID of the member account  
   - **Role name:** `OrganizationAccountAccessRole`  
3. Click **Switch Role.** You’re now operating inside the member account with full privileges.

### 7. Create Programmatic Access Keys for IaC

Inside the member account (while switched):

1. Open **IAM → Users → Add user.**  
2. Enter a name such as `iac-runner`.  
3. Select **Access key – Programmatic access.**  
4. When prompted for use case, choose **“Application running outside AWS.”**  
5. Attach a policy:
   - For a true sandbox: `AdministratorAccess`
   - Or for limited scope: a custom policy granting only needed services (EC2, IAM, S3, etc.)
6. Complete the wizard and copy the credentials when shown:
   ```
   AWS_ACCESS_KEY_ID=...
   AWS_SECRET_ACCESS_KEY=...
   AWS_REGION=us-east-1
   ```
7. Store the keys securely (e.g., password manager, secret manager, or CI/CD secrets).  

These credentials are now used by Terraform, CloudFormation, or any IaC system to deploy infrastructure within this sandbox account.

### 8. Verify and Maintain Access

- Users log in through the shared portal:  
  [https://yourcompany.awsapps.com/start](https://yourcompany.awsapps.com/start)
- You can **switch role** back to the management account anytime for organization-wide tasks.  
- Rotate access keys periodically (every 90–120 days).  
- Apply **Service Control Policies** or budgets to control costs if desired.

### 9. End State

You now have:

- A **Management Account** that owns the organization and central SSO.  
- A **Member Account (Sandbox)** isolated for IaC testing.  
- **IAM Identity Center users** for interactive console and CLI access.  
- **Programmatic IAM credentials** for automation tools.  

This setup provides strong isolation, centralized control, and a safe environment for running and testing Infrastructure-as-Code.
