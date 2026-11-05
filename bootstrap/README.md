# bootstrap/ — Terraform state backend

Creates the storage account that every other stack in this repo stores its state in. It is the
one stack that cannot use that backend, so it keeps its own state in `bootstrap/terraform.tfstate`
(declared `backend "local"`, gitignored). Back that file up, or accept re-creating the account.

## Run it

```bash
cp terraform.tfvars.example terraform.tfvars    # subscription_id, storage_account_name, owner
terraform init
terraform plan
terraform apply
terraform output backend_values                 # copy into ../env/<environment>/backend.hcl
```

`storage_account_name` is globally unique across Azure, so the example value will be taken — use
your own suffix.

## Security choices worth knowing before you change them

- **No access keys.** `shared_access_key_enabled = false` and `default_to_oauth_authentication = true`,
  so the backend authenticates with Entra ID and RBAC. That removes the credential issue #1 assumed
  would need Key Vault (issue #5) — there is nothing to store. Terraform docs also advise against the
  access-key auth method for new workloads.
- **Container-scoped RBAC.** `contributor_principal_ids` grants Storage Blob Data Contributor on the
  container only, not the account or the subscription. Add the CI workload identity's object ID here
  when issue #8 defines it; the identity Terraform runs as cannot read or write state without it.
- **Public network access stays on.** The state account must be reachable before issue #4 builds
  private endpoints, so `public_network_access = "Enabled"` with anonymous access off
  (`allow_nested_items_to_be_public = false`, private container). Revisit once private endpoints exist.
- **Versioning + soft delete.** Blob versioning is on and both blob and container soft-delete
  retention is `retention_days` (default 30), giving a recovery window for corrupted state.
  Locking itself comes from Azure blob leases, handled by the backend.

## Do not destroy casually

`terraform destroy` here deletes the container holding the state of stacks that still reference it.
Those stacks then look empty, and a later apply would recreate real Azure resources from scratch.
Remove the backend config from the affected stacks first, or never destroy this stack while they live.
