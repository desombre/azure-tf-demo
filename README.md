# azure-tf-demo
Demo project for Microsoft Azure in conjunction with Terraform

## Terraform Layout

One root stack composes reusable modules; environment differences live entirely in per-environment tfvars:

```
main.tf            # resource group + module composition
variables.tf       # root inputs
outputs.tf         # re-exported module outputs
backend.tf         # azurerm backend declaration (values supplied at init)
modules/vnet/      # reusable virtual network module
modules/subnet/    # subnet + optional NSG association + service delegation
modules/nsg/       # NSG with rules declared as separate resources
bootstrap/         # one-time state storage account (own local state)
env/dev/           # dev inputs + backend config (templates; real files are gitignored)
env/prod/          # prod inputs + backend config (templates; real files are gitignored)
```

## Usage

### Prerequisites

- Terraform >= 1.9.0 (input validations reference sibling variables for the subnet overlap check).
- Azure credentials. The provider resolves them in this order, so pick any one — the Azure CLI is **not** required:
  - `az login` (needs the `az` CLI installed), or
  - a service principal via `ARM_CLIENT_ID`, `ARM_CLIENT_SECRET`, `ARM_TENANT_ID`, `ARM_SUBSCRIPTION_ID`, or
  - workload identity federation in CI via `ARM_USE_OIDC` (needs the Actions workflow and the app registration).
- The state storage account, created once per environment by `bootstrap/`.

### Bootstrap the state backend (once per environment)

```bash
cp bootstrap/terraform.tfvars.example bootstrap/terraform.tfvars   # subscription_id, storage_account_name, owner
terraform -chdir=bootstrap init
terraform -chdir=bootstrap plan
terraform -chdir=bootstrap apply
terraform -chdir=bootstrap output backend_values                   # feeds the next section
```

`bootstrap/` keeps local state on purpose — it cannot store its state in the account it creates. See `bootstrap/README.md` for the security choices and the destroy warning.

### Apply a stack

State lives in Azure Blob Storage with native blob-lease locking, supplied per environment at init time (a `backend` block cannot read variables):

```bash
cp env/dev/backend.hcl.example env/dev/backend.hcl                 # paste storage_account_name from bootstrap
terraform init -backend-config=env/dev/backend.hcl
terraform validate
terraform plan  -var-file=env/dev/terraform.tfvars
terraform apply -var-file=env/dev/terraform.tfvars
```

If that environment already has a local `terraform.tfstate` from an earlier apply, add `-migrate-state` to the `terraform init` so Terraform pushes it into the new container.

Dev and Prod share one working directory, so the `key` line in each `backend.hcl` (`dev/terraform.tfstate` vs `prod/terraform.tfstate`) is what keeps the two states apart — always pass the matching backend config and var-file together.

Every value in the `*.example` files is a placeholder; a plan against real credentials fails on the all-zeros `subscription_id` until you set the Dev or Prod subscription.

## Secret Scanning Policy

This repository enforces secret scanning on every push and pull request to `develop` and `main` via [gitleaks](https://github.com/gitleaks/gitleaks).

- The CI check runs automatically — no manual action required.
- If a secret is detected, the pipeline **fails** and the PR cannot be merged until the secret is removed.
- Configuration lives in `.gitleaks.toml` at the repo root. Adjust allowlist rules there if you encounter false positives.
- Never commit secrets in clear text. Use Azure Key Vault (see issue #5) for all sensitive values.
