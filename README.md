# azure-tf-demo
Demo project for Microsoft Azure in conjunction with Terraform

## Secret Scanning Policy

This repository enforces secret scanning on every push and pull request to `develop` and `main` via [gitleaks](https://github.com/gitleaks/gitleaks).

- The CI check runs automatically — no manual action required.
- If a secret is detected, the pipeline **fails** and the PR cannot be merged until the secret is removed.
- Configuration lives in `.gitleaks.toml` at the repo root. Adjust allowlist rules there if you encounter false positives.
- Never commit secrets in clear text. Use Azure Key Vault (see issue #5) for all sensitive values.
