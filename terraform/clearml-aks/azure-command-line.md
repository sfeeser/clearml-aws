### Installing the Azure CLI (az)

You're spot on—that command (`az account list --output table`) runs in the **Azure Command-Line Interface (Azure CLI)**, a cross-platform tool for managing Azure resources from your terminal. It's free, open-source, and essential for scripting, Terraform auth, and quick checks like listing subscriptions.

Installation is straightforward and platform-specific. Below are **step-by-step guides** for the most common OSes (based on the official docs as of late 2024—always verify for updates). It installs the latest stable version (~2.65+). No admin rights needed on most systems.

#### Prerequisites (All Platforms)
- **Python**: Not required anymore (CLI is self-contained), but if you're on an older setup, ensure Python 3.8+ is available.
- **Internet access**: For downloading.
- **Terminal access**: PowerShell/Command Prompt on Windows, Terminal on macOS/Linux.

#### 1. **Windows** (Recommended: Winget or MSI)
   - **Via Winget** (built-in on Windows 10/11; fastest):
     1. Open **PowerShell as Administrator**.
     2. Run: `winget install Microsoft.AzureCLI`
     3. Close and reopen your terminal.
   - **Via MSI Installer** (if Winget isn't available):
     1. Download the `.msi` from [GitHub releases](https://aka.ms/installazurecliwindows) or [official page](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli-windows).
     2. Run the `.msi` file → Follow the wizard (defaults are fine).
     3. Restart your terminal.
   - **Via Chocolatey** (if you use it): `choco install azure-cli`

#### 2. **macOS** (Intel or Apple Silicon)
   - **Via Homebrew** (easiest):
     1. Install Homebrew if needed: `/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"`
     2. Run: `brew update && brew install azure-cli`
     3. Restart your terminal.
   - **Manual** (if no Homebrew):
     1. Download the `.pkg` from [GitHub releases](https://aka.ms/installazureclimag) or [official page](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli-macos).
     2. Run the `.pkg` → Follow prompts.
     3. Restart terminal.

#### 3. **Linux** (Ubuntu/Debian, RHEL/CentOS/Fedora, or Other Distros)
   - **Ubuntu/Debian** (via APT):
     1. Update packages: `curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash`
     2. (One-liner installs it.)
     3. Restart terminal.
   - **RHEL/CentOS/Fedora** (via YUM/DNF):
     1. Run: `curl -sL https://aka.ms/InstallAzureCLIRHEL | sudo bash` (RHEL/CentOS) or `curl -sL https://aka.ms/InstallAzureCLIFedora | sudo bash` (Fedora).
     2. Restart terminal.
   - **Other Distros** (e.g., Arch, Snap):
     - Snap: `sudo snap install azure-cli --classic`
     - Manual: Download the `.tar.gz` from [GitHub](https://aka.ms/installazureclilinux) → Extract → Add to PATH.

#### Verification & First Steps
1. **Check Installation**: Open a **new terminal** and run:
   ```bash
   az --version
   ```
   - Should output something like `azure-cli 2.65.0` (or newer).

2. **Login** (to use commands like `az account list`):
   ```bash
   az login
   ```
   - Opens a browser → Sign in with your Azure account.
   - For non-interactive (e.g., CI/CD): Use service principal as we discussed earlier.

3. **Test the Command**:
   ```bash
   az account list --output table
   ```
   - Lists your subscriptions (if logged in). If empty, check your access.

#### Troubleshooting
- **Permission errors**: Run as admin/sudo for installers.
- **PATH issues**: Add `export PATH=$PATH:~/.azure-cli/bin` to `~/.bashrc` or `~/.zshrc` and `source` it.
- **Older version**: Update with `az upgrade` (or reinstall).
- **WSL (Windows Subsystem for Linux)**: Install as Linux (Ubuntu works great).

Once installed, you'll be back to fixing that Terraform tenant error—run `az account list` to grab the **real `ARM_TENANT_ID`** from the `TenantId` column.

For full docs, head to [Microsoft's Azure CLI Install Guide](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli). If you're on a specific distro or hit a snag, share details! 🚀
