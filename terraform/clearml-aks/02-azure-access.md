# Azure Access via Command Line

### Lab Objective

This guide provides the steps to install necessary tools and perform local syntax and dry-run validation on the generated Terraform IaC artifact before deployment.

### Procedure

1. Set your environmental variables (azure keys). These are created previously so make sure you set them correctly.

    ```shell
      export ARM_TENANT_ID="xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
      export ARM_SUBSCRIPTION_ID="11111111-1111-1111-1111-111111111111"
      export ARM_CLIENT_ID="aaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee"
      export ARM_CLIENT_SECRET="*****"
    ```

0. Install the azure cli to login.

    `student@bchd:~$` `curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash`

0. Log in. 

    `student@bchd:~$` `az login`

    ```
    To sign in, use a web browser to open the page https://microsoft.com/devicelogin and enter the code <CODE-PROVIDED-HERE> to authenticate.
    ```

0. Follow the steps given to login via the web browser. You may have to use an authenticator app in addition to providing passkey / password. Once in, you can close the browser tab as it will tell you to do so. 

    <img width="476" height="363" alt="image" src="https://github.com/user-attachments/assets/52012af5-1781-4bde-95f4-cfdc3526b82d" />


0. Back on your terminal, you should see a new set of messages that look similar to the below:

    ```
    Retrieving tenants and subscriptions for the selection...
    
    [Tenant and subscription selection]
    
    No     Subscription name    Subscription ID                       Tenant
    -----  -------------------  ------------------------------------  --------
    [1] *  clearml              ahafahakah-73h3js-3757382-3lhaha-3jl  alta3
    
    The default is marked with an *; the default tenant is 'alta3' and subscription is 'clearml' (ahafahakah-73h3js-3757382-3lhaha-3jl).
    
    Select a subscription and tenant (Type a number or Enter for no changes): 
    ```

0. Your subscription ID will be different, but make sure you choose the one for this class.

   > Press **ENTER** for default

0. Take a look at your account

    `student@bchd:~$` `az account show`

    ```json
    {
      "environmentName": "AzureCloud",
      "homeTenantId": "crsk35x1-dall-45ha-9c22-pt1a6klm40ot",
      "id": "ahafahakah-73h3js-3757382-3lhaha-3jl",
      "isDefault": true,
      "managedByTenants": [],
      "name": "clearml",
      "state": "Enabled",
      "tenantDefaultDomain": "<tenantdefaultdomain>.onmicrosoft.com",
      "tenantDisplayName": "alta3",
      "tenantId": "crsk35x1-dall-45ha-9c22-pt1a6klm40ot",
      "user": {
        "name": "<your-username@domain.com",
        "type": "user"
      }
    }
    ```


0. Show your account in table format.

   `student@bchd:~$` `az account list --output table`

0. **OPTIONAL**: Show the resource list in case you end up changing what resources your config is using.

   `student@bchd:~$` `az vm list-skus --location eastus --all   --output table`

   > **THIS IS LONG OUTPUT SO IT MAY TAKE A MINUTE TO RUN**

