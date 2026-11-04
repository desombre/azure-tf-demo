# azure-tf-demo
Demo project for Microsoft Azure in conjunction with Terraform

## Terraform Layout

One root stack composes reusable modules; environment differences live entirely in per-environment tfvars:

```
main.tf            # resource group + module composition
variables.tf       # root inputs
outputs.tf         # re-exported module outputs
modules/vnet/      # reusable virtual network module
env/dev/           # dev inputs (terraform.tfvars.example template)
env/prod/          # prod inputs (terraform.tfvars.example template)
```

## Usage

`*.tfvars` files are gitignored, so start from the committed template:

```bash
cp env/dev/terraform.tfvars.example env/dev/terraform.tfvars   # then fill in subscription_id, owner
az login                                                        # or export ARM_CLIENT_ID/SECRET/SUBSCRIPTION_ID/TENANT_ID
terraform init
terraform validate
terraform plan  -var-file=env/dev/terraform.tfvars
terraform apply -var-file=env/dev/terraform.tfvars
```

Repeat with `env/prod/terraform.tfvars` for the Prod environment. State is local until the remote backend lands in issue #1.

## Secret Scanning Policy

This repository enforces secret scanning on every push and pull request to `develop` and `main` via [gitleaks](https://github.com/gitleaks/gitleaks).

- The CI check runs automatically — no manual action required.
- If a secret is detected, the pipeline **fails** and the PR cannot be merged until the secret is removed.
- Configuration lives in `.gitleaks.toml` at the repo root. Adjust allowlist rules there if you encounter false positives.
- Never commit secrets in clear text. Use Azure Key Vault (see issue #5) for all sensitive values.
