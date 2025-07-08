# Proxmox Infrastructure Module

This module handles all Proxmox Virtual Environment infrastructure for the Talos cluster, including VM templates, node instances, and networking configuration.

## Features

- Talos image download from the image factory
- VM template creation for control plane and worker nodes
- VM instance provisioning with flexible node distribution
- Static IP configuration with DHCP fallback
- Random VM ID assignment within configurable ranges
- Comprehensive resource validation

## Usage

```hcl
module "proxmox_infrastructure" {
  source = "./modules/proxmox-infrastructure"

  # Required variables
  network_cidr = "10.0.0.0/24"
  network_gateway = "10.0.0.1"
  schematic_id = module.talos_bootstrap.image_factory_schematic_id
  talos_image_filename = module.talos_bootstrap.talos_image_filename

  # Optional overrides
  cluster_name = "my-cluster"
  node_distribution = {
    "pve1" = {
      controlplane_count = 1
      worker_count = 2
    }
    "pve2" = {
      controlplane_count = 2
      worker_count = 1
    }
  }
  enable_dhcp = false
  controlplane_memory = 4096
  worker_memory = 8192
}
```

<!-- BEGIN_TF_DOCS -->
### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_proxmox"></a> [proxmox](#requirement\_proxmox) | ~> 0.79.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | ~> 3.1 |

### Providers

| Name | Version |
|------|---------|
| <a name="provider_proxmox"></a> [proxmox](#provider\_proxmox) | ~> 0.79.0 |
| <a name="provider_random"></a> [random](#provider\_random) | ~> 3.1 |

### Modules

No modules.

### Resources

| Name | Type |
|------|------|
| [proxmox_virtual_environment_download_file.talos_image](https://registry.terraform.io/providers/bpg/proxmox/latest/docs/resources/virtual_environment_download_file) | resource |
| [proxmox_virtual_environment_vm.nodes](https://registry.terraform.io/providers/bpg/proxmox/latest/docs/resources/virtual_environment_vm) | resource |
| [proxmox_virtual_environment_vm.template](https://registry.terraform.io/providers/bpg/proxmox/latest/docs/resources/virtual_environment_vm) | resource |
| [random_integer.node_vm_id](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/integer) | resource |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | Name of the Talos cluster | `string` | `"talos"` | no |
| <a name="input_common_tags"></a> [common\_tags](#input\_common\_tags) | Common tags to apply to all resources | `list(string)` | <pre>[<br/>  "talos",<br/>  "terraform"<br/>]</pre> | no |
| <a name="input_controlplane_cpu_cores"></a> [controlplane\_cpu\_cores](#input\_controlplane\_cpu\_cores) | Number of CPU cores for control plane nodes | `number` | `4` | no |
| <a name="input_controlplane_disk_size"></a> [controlplane\_disk\_size](#input\_controlplane\_disk\_size) | Disk size for control plane nodes in GB | `number` | `20` | no |
| <a name="input_controlplane_ip_start"></a> [controlplane\_ip\_start](#input\_controlplane\_ip\_start) | Starting IP address for control plane nodes (last octet) (ignored when enable\_dhcp is true) | `number` | `50` | no |
| <a name="input_controlplane_memory"></a> [controlplane\_memory](#input\_controlplane\_memory) | Memory for control plane nodes in MB | `number` | `4096` | no |
| <a name="input_controlplane_template_id"></a> [controlplane\_template\_id](#input\_controlplane\_template\_id) | VM ID for the control plane template | `number` | `998` | no |
| <a name="input_controlplane_vm_id_max"></a> [controlplane\_vm\_id\_max](#input\_controlplane\_vm\_id\_max) | Maximum VM ID for control plane nodes | `number` | `2999` | no |
| <a name="input_controlplane_vm_id_min"></a> [controlplane\_vm\_id\_min](#input\_controlplane\_vm\_id\_min) | Minimum VM ID for control plane nodes | `number` | `2000` | no |
| <a name="input_cpu_type"></a> [cpu\_type](#input\_cpu\_type) | CPU type for VMs | `string` | `"x86-64-v2-AES"` | no |
| <a name="input_dns_servers"></a> [dns\_servers](#input\_dns\_servers) | List of DNS servers for Talos nodes (applied regardless of enable\_dhcp setting) | `list(string)` | <pre>[<br/>  "1.1.1.1",<br/>  "1.0.0.1"<br/>]</pre> | no |
| <a name="input_enable_dhcp"></a> [enable\_dhcp](#input\_enable\_dhcp) | Enable DHCP for node network interfaces. When true, static IP variables (network\_cidr, network\_gateway, controlplane\_ip\_start, worker\_ip\_start) are ignored | `bool` | `false` | no |
| <a name="input_extra_tags"></a> [extra\_tags](#input\_extra\_tags) | Extra tags to add to resources | `list(string)` | `[]` | no |
| <a name="input_image_download_node"></a> [image\_download\_node](#input\_image\_download\_node) | Proxmox node where Talos disk images are downloaded | `string` | `"pve"` | no |
| <a name="input_network_bridge"></a> [network\_bridge](#input\_network\_bridge) | Network bridge for VM network interfaces | `string` | `"vmbr0"` | no |
| <a name="input_network_cidr"></a> [network\_cidr](#input\_network\_cidr) | Network CIDR for node IP addresses (ignored when enable\_dhcp is true) | `string` | n/a | yes |
| <a name="input_network_gateway"></a> [network\_gateway](#input\_network\_gateway) | Network gateway IP address (ignored when enable\_dhcp is true) | `string` | n/a | yes |
| <a name="input_network_interface"></a> [network\_interface](#input\_network\_interface) | Network interface name for node network configuration | `string` | `"eth0"` | no |
| <a name="input_node_distribution"></a> [node\_distribution](#input\_node\_distribution) | Distribution of VMs across Proxmox nodes | <pre>map(object({<br/>    controlplane_count = number<br/>    worker_count       = number<br/>  }))</pre> | <pre>{<br/>  "pve": {<br/>    "controlplane_count": 3,<br/>    "worker_count": 3<br/>  }<br/>}</pre> | no |
| <a name="input_schematic_id"></a> [schematic\_id](#input\_schematic\_id) | Talos image factory schematic ID | `string` | n/a | yes |
| <a name="input_talos_disk_image_datastore_id"></a> [talos\_disk\_image\_datastore\_id](#input\_talos\_disk\_image\_datastore\_id) | Datastore for downloading Talos disk images | `string` | `"local"` | no |
| <a name="input_talos_image_filename"></a> [talos\_image\_filename](#input\_talos\_image\_filename) | Talos image filename | `string` | n/a | yes |
| <a name="input_talos_version"></a> [talos\_version](#input\_talos\_version) | Version of Talos Linux to use | `string` | `"v1.10.5"` | no |
| <a name="input_template_datastore_id"></a> [template\_datastore\_id](#input\_template\_datastore\_id) | Datastore for VM template disks | `string` | `"local-lvm"` | no |
| <a name="input_template_node"></a> [template\_node](#input\_template\_node) | Proxmox node where VM templates are created | `string` | `"pve"` | no |
| <a name="input_vm_datastore_id"></a> [vm\_datastore\_id](#input\_vm\_datastore\_id) | Datastore for VM initialization | `string` | `"local-lvm"` | no |
| <a name="input_worker_cpu_cores"></a> [worker\_cpu\_cores](#input\_worker\_cpu\_cores) | Number of CPU cores for worker nodes | `number` | `8` | no |
| <a name="input_worker_disk_size"></a> [worker\_disk\_size](#input\_worker\_disk\_size) | Disk size for worker nodes in GB | `number` | `50` | no |
| <a name="input_worker_ip_start"></a> [worker\_ip\_start](#input\_worker\_ip\_start) | Starting IP address for worker nodes (last octet) (ignored when enable\_dhcp is true) | `number` | `70` | no |
| <a name="input_worker_memory"></a> [worker\_memory](#input\_worker\_memory) | Memory for worker nodes in MB | `number` | `8192` | no |
| <a name="input_worker_template_id"></a> [worker\_template\_id](#input\_worker\_template\_id) | VM ID for the worker template | `number` | `999` | no |
| <a name="input_worker_vm_id_max"></a> [worker\_vm\_id\_max](#input\_worker\_vm\_id\_max) | Maximum VM ID for worker nodes | `number` | `3999` | no |
| <a name="input_worker_vm_id_min"></a> [worker\_vm\_id\_min](#input\_worker\_vm\_id\_min) | Minimum VM ID for worker nodes | `number` | `3000` | no |

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_controlplane_nodes"></a> [controlplane\_nodes](#output\_controlplane\_nodes) | Map of controlplane nodes with their endpoints and VM IDs |
| <a name="output_first_controlplane_endpoint"></a> [first\_controlplane\_endpoint](#output\_first\_controlplane\_endpoint) | Endpoint of the first controlplane node |
| <a name="output_first_controlplane_node"></a> [first\_controlplane\_node](#output\_first\_controlplane\_node) | Node address of the first controlplane node |
| <a name="output_nodes"></a> [nodes](#output\_nodes) | All VM nodes (controlplane and worker) |
| <a name="output_talos_image"></a> [talos\_image](#output\_talos\_image) | Downloaded Talos image |
| <a name="output_templates"></a> [templates](#output\_templates) | VM templates |
| <a name="output_worker_nodes"></a> [worker\_nodes](#output\_worker\_nodes) | Map of worker nodes with their endpoints and VM IDs |
<!-- END_TF_DOCS -->
