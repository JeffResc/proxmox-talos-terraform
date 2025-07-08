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
| <a name="input_ccm_token_id"></a> [ccm\_token\_id](#input\_ccm\_token\_id) | Proxmox CCM token ID | `string` | n/a | yes |
| <a name="input_ccm_token_secret"></a> [ccm\_token\_secret](#input\_ccm\_token\_secret) | Proxmox CCM token secret | `string` | n/a | yes |
| <a name="input_cluster_endpoint_override"></a> [cluster\_endpoint\_override](#input\_cluster\_endpoint\_override) | Custom cluster endpoint URL. Only used when cluster\_vip\_enabled is false. Must include protocol and port. | `string` | `null` | no |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | Name of the Talos cluster | `string` | `"talos"` | no |
| <a name="input_cluster_vip_enabled"></a> [cluster\_vip\_enabled](#input\_cluster\_vip\_enabled) | Enable VIP (Virtual IP) for cluster endpoint. When true, cluster\_vip\_ip is used as the cluster endpoint. | `bool` | `true` | no |
| <a name="input_cluster_vip_ip"></a> [cluster\_vip\_ip](#input\_cluster\_vip\_ip) | IP address for the cluster VIP (Virtual IP). Required when cluster\_vip\_enabled is true. | `string` | `null` | no |
| <a name="input_controlplane_nodes"></a> [controlplane\_nodes](#input\_controlplane\_nodes) | Map of controlplane nodes with their endpoints and VM IDs | <pre>map(object({<br/>    endpoint = string<br/>    node     = string<br/>    vm_id    = string<br/>  }))</pre> | n/a | yes |
| <a name="input_enable_dhcp"></a> [enable\_dhcp](#input\_enable\_dhcp) | Enable DHCP for node network interfaces. When true, static IP variables are ignored | `bool` | `false` | no |
| <a name="input_first_controlplane_endpoint"></a> [first\_controlplane\_endpoint](#input\_first\_controlplane\_endpoint) | Endpoint of the first controlplane node | `string` | n/a | yes |
| <a name="input_first_controlplane_node"></a> [first\_controlplane\_node](#input\_first\_controlplane\_node) | Node address of the first controlplane node | `string` | n/a | yes |
| <a name="input_network_interface"></a> [network\_interface](#input\_network\_interface) | Network interface name for node network configuration | `string` | `"eth0"` | no |
| <a name="input_nodes_ready"></a> [nodes\_ready](#input\_nodes\_ready) | Dependency variable to ensure nodes are ready | `any` | `null` | no |
| <a name="input_proxmox_endpoint"></a> [proxmox\_endpoint](#input\_proxmox\_endpoint) | Proxmox Virtual Environment API endpoint URL | `string` | `"https://your-proxmox:8006/"` | no |
| <a name="input_proxmox_insecure"></a> [proxmox\_insecure](#input\_proxmox\_insecure) | Skip TLS certificate verification for Proxmox API | `bool` | `false` | no |
| <a name="input_talos_version"></a> [talos\_version](#input\_talos\_version) | Version of Talos Linux to use | `string` | `"v1.10.5"` | no |
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
