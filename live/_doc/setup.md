# Setting up your workstation for Cloud City IaC management

Eventually, most IaC tasks will be done inside GitLab pipelines, but at present much of the management is done from developer workstations.

# Install Requirements

To set up your workstation for IaC/Terragrunt usage, do the following:

1. Clone this repo into a folder on your workstation. You may need to [connect to the AWS VPN](https://confluence.fan.gov/display/CCPL/CloudCity+Client+VPN) to do so.
2. Clone the [`modules`](https://gitlab.cloud-city/cloud-city/platform/iac/modules) repo into a folder adjacent to this one (so that both `live` and `modules` are in the same folder at the same level).
3. In your shell, `cd` into the root of this repo's checkout, and run `./install_or_update_bespinctl.bash`, answer the prompts to install any required tooling.
4. Restart your shell, and make sure you can do `bespinctl --help`; that confirms that the tooling is installed on your PATH.
   - If this doesn't work, 
5. Do `bespinctl clear-caches` and ensure it succeeds, as a simple smoke-test.
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

To update `bespinctl` to contain the latest tooling changes, run `./install_or_update_bespinctl.bash`. This command is intended to be idempotent and to fix several common issues if run on an existing installation.

# Troubleshooting

If things were working before and they broke (e.g. you're getting Python errors in `bespinctl` or other issues are coming up), try the following (in any order, continuing if one command fails):
- Make sure you are using `bespinctl iac terragrunt` and not running `terragrunt`-the-program directly; set a shell alias or uninstall terragrunt if this keeps happening.
- Disconnect/reconnect the AWS VPN, if you are using it.
- Do `bespinctl clear-caches --execute`. 
- Restart your shell.
- Check your PATH, e.g. `which bespinctl`.
- Run `./install_or_update_bespinctl.bash` again.

# Install troubleshooting

If issues occur installing `bespinctl`, either seek help or check out the commands in `install_or_update_bespinctl.bash` to fix things up by hand (and make an MR to improve the tooling to avoid issues encountered!); using `set -x` in the shell before running the script will produce debug information.

If you're having trouble getting `bespinctl` located (e.g. 'command not found'), use `uv` (which should also be on your PATH, but if it isn't, you can find it at `~/.local/bin/uv`, where `~` is your home directory) and run `uv tool update-shell`, restart your shell, and then try again.