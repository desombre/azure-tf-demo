terraform {
  # State lives in a dedicated Azure Storage Account (issue #1). The values are intentionally
  # absent here: a backend block cannot take variables, so they are supplied per environment at
  # init time from env/<environment>/backend.hcl.
  #
  #   terraform init -backend-config=env/dev/backend.hcl
  #
  # Run bootstrap/ first to create the account, and lock the file down to one environment per
  # working directory — the key in backend.hcl already names the environment.
  backend "azurerm" {}
}
