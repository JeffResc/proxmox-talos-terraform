# Talos Bootstrap Module

This module handles Talos Linux configuration and cluster bootstrapping. It creates the necessary Talos machine configurations, applies them to nodes, and bootstraps the cluster.

## Features

- Talos image factory schematic generation with system extensions
- Machine secrets generation for cluster security
- Separate configurations for control plane and worker nodes
- Cluster bootstrapping on the first control plane node
- Kubeconfig generation for cluster access
- Proxmox Cloud Controller Manager integration

## Usage

```hcl
module "talos_bootstrap" {
  source = "./modules/talos-bootstrap"

  # Required variables
  ccm_token_id            = module.proxmox_ccm.ccm_token_id
  ccm_token_secret        = module.proxmox_ccm.ccm_token_secret
  controlplane_nodes      = module.proxmox_infrastructure.controlplane_nodes
  worker_nodes            = module.proxmox_infrastructure.worker_nodes
  first_controlplane_endpoint = module.proxmox_infrastructure.first_controlplane_endpoint
  first_controlplane_node = module.proxmox_infrastructure.first_controlplane_node
  nodes_ready             = module.proxmox_infrastructure.nodes

  # Optional overrides
  talos_version = "v1.10.5"
  cluster_name = "my-cluster"
  cluster_vip_enabled = true
  cluster_vip_ip = "10.0.0.100"
}
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_talos"></a> [talos](#requirement\_talos) | ~> 0.8.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_talos"></a> [talos](#provider\_talos) | 0.8.1 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [talos_cluster_kubeconfig.this](https://registry.terraform.io/providers/siderolabs/talos/latest/docs/resources/cluster_kubeconfig) | resource |
| [talos_image_factory_schematic.this](https://registry.terraform.io/providers/siderolabs/talos/latest/docs/resources/image_factory_schematic) | resource |
| [talos_machine_bootstrap.this](https://registry.terraform.io/providers/siderolabs/talos/latest/docs/resources/machine_bootstrap) | resource |
| [talos_machine_configuration_apply.controlplane](https://registry.terraform.io/providers/siderolabs/talos/latest/docs/resources/machine_configuration_apply) | resource |
| [talos_machine_configuration_apply.worker](https://registry.terraform.io/providers/siderolabs/talos/latest/docs/resources/machine_configuration_apply) | resource |
| [talos_machine_secrets.this](https://registry.terraform.io/providers/siderolabs/talos/latest/docs/resources/machine_secrets) | resource |
| [talos_image_factory_extensions_versions.this](https://registry.terraform.io/providers/siderolabs/talos/latest/docs/data-sources/image_factory_extensions_versions) | data source |
| [talos_machine_configuration.controlplane](https://registry.terraform.io/providers/siderolabs/talos/latest/docs/data-sources/machine_configuration) | data source |
| [talos_machine_configuration.worker](https://registry.terraform.io/providers/siderolabs/talos/latest/docs/data-sources/machine_configuration) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_ccm_token_id"></a> [ccm\_token\_id](#input\_ccm\_token\_id) | CCM token ID from the CCM module | `string` | `""` | no |
| <a name="input_ccm_token_secret"></a> [ccm\_token\_secret](#input\_ccm\_token\_secret) | CCM token secret from the CCM module | `string` | `""` | no |
| <a name="input_cluster_config"></a> [cluster\_config](#input\_cluster\_config) | Cluster configuration settings | <pre>object({<br/>    name          = string<br/>    talos_version = optional(string, "v1.10.5") # renovate: datasource=github-releases depName=siderolabs/talos<br/>    vip = optional(object({<br/>      enabled = bool<br/>      ip      = optional(string)<br/>      }), {<br/>      enabled = true<br/>      ip      = null<br/>    })<br/>    endpoint_override = optional(string)<br/>  })</pre> | n/a | yes |
| <a name="input_controlplane_nodes"></a> [controlplane\_nodes](#input\_controlplane\_nodes) | Map of controlplane nodes with their endpoints and VM IDs | <pre>map(object({<br/>    endpoint = string<br/>    node     = string<br/>    vm_id    = string<br/>  }))</pre> | n/a | yes |
| <a name="input_first_controlplane_endpoint"></a> [first\_controlplane\_endpoint](#input\_first\_controlplane\_endpoint) | Endpoint of the first controlplane node | `string` | n/a | yes |
| <a name="input_first_controlplane_node"></a> [first\_controlplane\_node](#input\_first\_controlplane\_node) | Node address of the first controlplane node | `string` | n/a | yes |
| <a name="input_network_config"></a> [network\_config](#input\_network\_config) | Network configuration for Talos nodes | <pre>object({<br/>    enable_dhcp = optional(bool, false)<br/>    cidr        = string<br/>    gateway     = string<br/>    bridge      = optional(string, "vmbr0")<br/>    interface   = optional(string, "eth0")<br/>  })</pre> | n/a | yes |
| <a name="input_nodes_ready"></a> [nodes\_ready](#input\_nodes\_ready) | Dependency variable to ensure nodes are ready | `any` | `null` | no |
| <a name="input_proxmox_config"></a> [proxmox\_config](#input\_proxmox\_config) | Proxmox connection and infrastructure configuration | <pre>object({<br/>    host      = string<br/>    port      = optional(number, 8006)<br/>    api_token = string<br/>    insecure  = optional(bool, false)<br/><br/>    node_name                     = optional(string, "pve")<br/>    talos_disk_image_datastore_id = optional(string, "local")<br/>    template_datastore_id         = optional(string, "local-lvm")<br/>    vm_datastore_id               = optional(string, "local-lvm")<br/><br/>    dns_servers = optional(list(string), ["1.1.1.1", "8.8.8.8"])<br/><br/>    # SSH configuration for routing setup (optional)<br/>    ssh_config = optional(object({<br/>      ssh_user        = optional(string, "root")<br/>      ssh_private_key = string # Path to SSH private key (required for NAT gateway)<br/>    }))<br/><br/>    ccm_config = optional(object({<br/>      enabled    = bool<br/>      user       = optional(string, "talos-ccm@pve")<br/>      role       = optional(string, "TalosCCM")<br/>      token_name = optional(string, "ccm-token")<br/>      privileges = optional(list(string), ["VM.Audit"])<br/>      }), {<br/>      enabled    = true<br/>      user       = "talos-ccm@pve"<br/>      role       = "TalosCCM"<br/>      token_name = "ccm-token"<br/>      privileges = ["VM.Audit"]<br/>    })<br/>  })</pre> | n/a | yes |
| <a name="input_worker_nodes"></a> [worker\_nodes](#input\_worker\_nodes) | Map of worker nodes with their endpoints and VM IDs | <pre>map(object({<br/>    endpoint = string<br/>    node     = string<br/>    vm_id    = string<br/>  }))</pre> | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_client_configuration"></a> [client\_configuration](#output\_client\_configuration) | Talos client configuration |
| <a name="output_controlplane_machine_configuration"></a> [controlplane\_machine\_configuration](#output\_controlplane\_machine\_configuration) | Controlplane machine configuration |
| <a name="output_image_factory_schematic_id"></a> [image\_factory\_schematic\_id](#output\_image\_factory\_schematic\_id) | Talos image factory schematic ID |
| <a name="output_kubeconfig"></a> [kubeconfig](#output\_kubeconfig) | Kubernetes configuration for kubectl |
| <a name="output_talos_config"></a> [talos\_config](#output\_talos\_config) | Talos configuration for talosctl |
| <a name="output_talos_image_filename"></a> [talos\_image\_filename](#output\_talos\_image\_filename) | Talos image filename |
| <a name="output_worker_machine_configuration"></a> [worker\_machine\_configuration](#output\_worker\_machine\_configuration) | Worker machine configuration |
<!-- END_TF_DOCS -->
