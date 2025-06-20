# Setting up your workstation for Cloud City IaC management

Eventually, most IaC tasks will be done inside GitLab pipelines, but at present much of the management is done from developer workstations.

# Install Requirements

To set up your workstation for IaC/Terragrunt usage, do the following:

1. Clone this repo into a folder on your workstation. You may need to [connect to the AWS VPN](https://confluence.fan.gov/display/CCPL/CloudCity+Client+VPN) to do so.
2. Clone the [`modules`](https://gitlab.cloud-city/cloud-city/platform/iac/modules) repo into a folder adjacent to this one (so that both `live` and `modules` are in the same folder at the same level).
3. In your shell, `cd` into the root of this repo's checkout.
4. Run `<path to live repo>/install_or_update_bespinctl.bash`, answer the prompts to install any required tooling.
   - **Note for Windows users:** If errors occur on Windows, do **not** re-run this command in an elevated command prompt. Unless you use WSL for your everyday development, do not run it in WSL either. Instead, if issues occur with this step, try re-running this command in either your IDE's integrated terminal or Git Bash. Once this command has succeeded in one shell, `bespinctl` should work from other shells on the same computer as well.
5. Restart your shell, and make sure you can do `bespinctl --help`; that confirms that the tooling is installed on your PATH.
   - **Note:** If you use an IDE-integrated terminal (such as the one in Visual Studio Code or PyCharm), you will have to close and re-open all instances of your IDE application, not just the terminal window.
   - **Note for Windows users:** Windows users may also have to restart their workstation or development environment if this step fails.
6. Do `bespinctl iac lint` for a more thorough smoke-test.

# Non-Requirements

In order to use this repo and run IaC/automations/tools in Cloud City, you do *not* need:
- Terraform to be installed.
- Terragrunt to be installed.
- The AWS CLI to be installed.
- Any AWS config files, profiles, or credentials to be set up.

You are welcome to install those things on your own for your own purposes, but they are not required on for any of the regular tooling to work.

The `bespinctl` system does not interact with or honor the configuration or presence of external tools, so they're safe to co-exist.

Most IaC usage in this repo does not require being connected to the [AWS VPN](https://confluence.fan.gov/display/CCPL/CloudCity+Client+VPN), but some IaC tasks (generally, anything involving a Kubernetes cluster being interacted with or managed by Terraform) does.

# Updating

To update `bespinctl` to contain the latest tooling changes, run `<path to live repo>/install_or_update_bespinctl.bash`. 

This command is intended to be idempotent and to fix several common issues if run on an existing installation.

# Troubleshooting

If things were working before and they broke (e.g. you're getting Python errors in `bespinctl` or other issues are coming up), try the following.

**Run these steps in any order, _continuing if one command fails_**.

- Run `<path to live repo>/install_or_update_bespinctl.bash`
  - This command is safe to re-run any time. 
  - **It is expected that you will have to run this command if upstream `bespinctl` updates have been made. `git pull`ing latest `live` code is not sufficient to get `bespinctl` updates; you need to run this command after pulling.**
- Make sure you are using the right `terragrunt` and `terraform`:
  - After running the install script, `terragrunt` should run the same command as `bespinctl iac terragrunt`. If that is not the case (e.g. `bespinctl iac terragrunt -version` doesn't match the output of `terragrunt -version`), you should uninstall any manually-installed `terragrunt`, `terraform`, or `terraform-docs` binaries that previously existed on your workstation.
- Disconnect/reconnect the AWS VPN, if you are using it.
- Restart your shell.
- If you are using an IDE-integrated terminal (e.g.  VS Code), restart your IDE.
  - Make sure to close all windows/instances of your IDE when restarting it.
- Restart your computer.
- Gather debug info and ask for help. To run `bespinctl` and the installer script in debug mode, set the environment variable `DOS_CLOUD_CITY_BESPINCTL_DEBUG`, e.g. via `export DOS_CLOUD_CITY_BESPINCTL_DEBUG=1`.

# Install troubleshooting

If issues occur installing `bespinctl`, either seek help or check out the code in `install_or_update_bespinctl.bash` to fix things up by hand (and make an MR to improve the tooling to avoid issues encountered!); using `set -x` in the shell before running the script will produce debug information.

If you're having trouble getting `bespinctl` located (e.g. 'command not found'), use `uv` (which should also be on your PATH, but if it isn't, you can find it at `~/.local/bin/uv`, where `~` is your home directory) and run `uv tool update-shell`, restart your shell, and then try again.