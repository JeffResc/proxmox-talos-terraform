# Proxmox Cloud Controller Manager Module

This module sets up the Proxmox Cloud Controller Manager (CCM) by creating the necessary user, role, and API token in Proxmox VE.

## Features

- Creates a dedicated role with VM.Audit privileges
- Creates a service account user for the CCM
- Generates an API token for authentication
- Configures proper ACL permissions

## Usage

```hcl
module "proxmox_ccm" {
  source = "./modules/proxmox-ccm"

  # Optional overrides
  proxmox_ccm_user = "talos-ccm@pve"
  proxmox_ccm_role = "TalosCCM"
}
```

<!-- BEGIN_TF_DOCS -->
### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_proxmox"></a> [proxmox](#requirement\_proxmox) | ~> 0.79.0 |

### Providers

| Name | Version |
|------|---------|
| <a name="provider_proxmox"></a> [proxmox](#provider\_proxmox) | ~> 0.79.0 |

### Modules

No modules.

### Resources

| Name | Type |
|------|------|
| [proxmox_virtual_environment_role.ccm](https://registry.terraform.io/providers/bpg/proxmox/latest/docs/resources/virtual_environment_role) | resource |
| [proxmox_virtual_environment_user.ccm](https://registry.terraform.io/providers/bpg/proxmox/latest/docs/resources/virtual_environment_user) | resource |
| [proxmox_virtual_environment_user_token.ccm](https://registry.terraform.io/providers/bpg/proxmox/latest/docs/resources/virtual_environment_user_token) | resource |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_proxmox_ccm_role"></a> [proxmox\_ccm\_role](#input\_proxmox\_ccm\_role) | Proxmox role for Cloud Controller Manager | `string` | `"TalosCCM"` | no |
| <a name="input_proxmox_ccm_user"></a> [proxmox\_ccm\_user](#input\_proxmox\_ccm\_user) | Proxmox user for Cloud Controller Manager | `string` | `"talos-ccm@pve"` | no |

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_ccm_role"></a> [ccm\_role](#output\_ccm\_role) | Proxmox CCM role |
| <a name="output_ccm_token"></a> [ccm\_token](#output\_ccm\_token) | Proxmox CCM token |
| <a name="output_ccm_token_id"></a> [ccm\_token\_id](#output\_ccm\_token\_id) | Proxmox CCM token ID |
| <a name="output_ccm_token_secret"></a> [ccm\_token\_secret](#output\_ccm\_token\_secret) | Proxmox CCM token secret |
| <a name="output_ccm_user"></a> [ccm\_user](#output\_ccm\_user) | Proxmox CCM user |
<!-- END_TF_DOCS -->