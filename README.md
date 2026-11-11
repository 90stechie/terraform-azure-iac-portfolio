# Azure Infrastructure as Code Portfolio

Reusable Terraform modules for provisioning and operating production-grade
workloads on Microsoft Azure — the same patterns I use for hybrid cloud
landing zones, AKS platforms, and enterprise identity.

## What is in here

| Module | What it builds |
|---|---|
| `modules/aks` | AKS cluster with system + user node pools, Azure CNI networking, managed identity, Entra ID RBAC, Key Vault secrets provider, and autoscaling |
| `modules/azure-monitor` | Log Analytics workspace and action group; AKS CPU/memory alerts are wired up in the root composition |
| `modules/hybrid-identity` | Entra ID groups and service principal, Key Vault with private endpoint, and least-privilege role assignments |

`examples/complete` wires all three modules together into a full deployment:
resource group, VNet, AKS, monitoring, and identity.

## Quick start

```bash
# 1. Log in to Azure
az login
az account set --subscription "<subscription-id>"

# 2. Configure your values
cp terraform.tfvars.example terraform.tfvars
# edit terraform.tfvars

# 3. Deploy the example
cd examples/complete
terraform init
terraform plan
terraform apply
```

Requirements: Terraform >= 1.5, Azure CLI, and an Azure subscription with
permissions to create resource groups, VNets, AKS clusters, Key Vaults, and
Entra ID objects.

## Layout

```
.
├── main.tf                    # Root composition: RG, VNet, modules
├── variables.tf
├── outputs.tf
├── providers.tf
├── terraform.tfvars.example
├── modules/
│   ├── aks/                   # AKS cluster + user node pool
│   ├── azure-monitor/         # Workspace, alerts, diagnostics
│   └── hybrid-identity/       # Entra ID, Key Vault, RBAC
└── examples/
    └── complete/              # End-to-end deployment
```

## Design notes

- **No secrets in this repo.** `terraform.tfvars` is git-ignored; secrets
  live in Key Vault and are injected through the secrets provider.
- **Least privilege.** Service principals and managed identities get scoped
  role assignments only — no subscription-wide Contributor.
- **Private by default.** Key Vault sits behind a private endpoint and the
  network ACLs deny public access.
- **Observable from day one.** Every cluster ships with Log Analytics,
  diagnostic settings, and alerts for CPU, memory, and node health.

## Remote state

For team use, uncomment the `backend "azurerm"` block in `providers.tf`
and point it at a dedicated state storage account. State files can contain
sensitive values — never commit them.

## Author

Prasanth Namana — Senior IT Infrastructure Consultant (Azure, AWS,
VMware, Terraform). [LinkedIn](https://www.linkedin.com/in/prasanth-namana)

## License

MIT — see [LICENSE](LICENSE).
