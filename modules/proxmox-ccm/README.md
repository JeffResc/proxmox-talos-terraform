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
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_proxmox"></a> [proxmox](#requirement\_proxmox) | ~> 0.79.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_proxmox"></a> [proxmox](#provider\_proxmox) | 0.79.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [proxmox_virtual_environment_role.ccm](https://registry.terraform.io/providers/bpg/proxmox/latest/docs/resources/virtual_environment_role) | resource |
| [proxmox_virtual_environment_user.ccm](https://registry.terraform.io/providers/bpg/proxmox/latest/docs/resources/virtual_environment_user) | resource |
| [proxmox_virtual_environment_user_token.ccm](https://registry.terraform.io/providers/bpg/proxmox/latest/docs/resources/virtual_environment_user_token) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_ccm_config"></a> [ccm\_config](#input\_ccm\_config) | Configuration for Proxmox Cloud Controller Manager | <pre>object({<br/>    enabled    = bool<br/>    user       = optional(string, "talos-ccm@pve")<br/>    role       = optional(string, "TalosCCM")<br/>    token_name = optional(string, "ccm-token")<br/>    privileges = optional(list(string), ["VM.Audit"])<br/>  })</pre> | <pre>{<br/>  "enabled": true,<br/>  "privileges": [<br/>    "VM.Audit"<br/>  ],<br/>  "role": "TalosCCM",<br/>  "token_name": "ccm-token",<br/>  "user": "talos-ccm@pve"<br/>}</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_ccm_role"></a> [ccm\_role](#output\_ccm\_role) | Proxmox CCM role |
| <a name="output_ccm_token"></a> [ccm\_token](#output\_ccm\_token) | Proxmox CCM token |
| <a name="output_ccm_token_id"></a> [ccm\_token\_id](#output\_ccm\_token\_id) | Proxmox CCM token ID |
| <a name="output_ccm_token_secret"></a> [ccm\_token\_secret](#output\_ccm\_token\_secret) | Proxmox CCM token secret |
| <a name="output_ccm_user"></a> [ccm\_user](#output\_ccm\_user) | Proxmox CCM user |
<!-- END_TF_DOCS -->
