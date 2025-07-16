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
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_proxmox"></a> [proxmox](#requirement\_proxmox) | ~> 0.79.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | ~> 3.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_proxmox"></a> [proxmox](#provider\_proxmox) | 0.79.0 |
| <a name="provider_random"></a> [random](#provider\_random) | 3.7.2 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [proxmox_virtual_environment_download_file.talos_image](https://registry.terraform.io/providers/bpg/proxmox/latest/docs/resources/virtual_environment_download_file) | resource |
| [proxmox_virtual_environment_vm.nodes](https://registry.terraform.io/providers/bpg/proxmox/latest/docs/resources/virtual_environment_vm) | resource |
| [proxmox_virtual_environment_vm.template](https://registry.terraform.io/providers/bpg/proxmox/latest/docs/resources/virtual_environment_vm) | resource |
| [random_integer.node_vm_id](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/integer) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cluster_config"></a> [cluster\_config](#input\_cluster\_config) | Cluster configuration settings | <pre>object({<br/>    name          = string<br/>    talos_version = optional(string, "v1.10.5") # renovate: datasource=github-releases depName=siderolabs/talos<br/>    vip = optional(object({<br/>      enabled = bool<br/>      ip      = optional(string)<br/>      }), {<br/>      enabled = true<br/>      ip      = null<br/>    })<br/>    endpoint_override = optional(string)<br/>  })</pre> | n/a | yes |
| <a name="input_network_config"></a> [network\_config](#input\_network\_config) | Network configuration for Talos nodes | <pre>object({<br/>    enable_dhcp = optional(bool, false)<br/>    cidr        = string<br/>    gateway     = string<br/>    bridge      = optional(string, "vmbr0")<br/>    interface   = optional(string, "eth0")<br/>  })</pre> | n/a | yes |
| <a name="input_node_config"></a> [node\_config](#input\_node\_config) | Node configuration for the cluster | <pre>object({<br/>    controlplane_count    = number<br/>    worker_count          = number<br/>    controlplane_ip_start = optional(number, 10)<br/>    worker_ip_start       = optional(number, 20)<br/>  })</pre> | <pre>{<br/>  "controlplane_count": 3,<br/>  "worker_count": 3<br/>}</pre> | no |
| <a name="input_node_distribution"></a> [node\_distribution](#input\_node\_distribution) | Distribution of VMs across Proxmox nodes | <pre>map(object({<br/>    controlplane_count = number<br/>    worker_count       = number<br/>  }))</pre> | <pre>{<br/>  "pve": {<br/>    "controlplane_count": 3,<br/>    "worker_count": 3<br/>  }<br/>}</pre> | no |
| <a name="input_proxmox_config"></a> [proxmox\_config](#input\_proxmox\_config) | Proxmox connection and infrastructure configuration | <pre>object({<br/>    endpoint  = string<br/>    api_token = string<br/>    insecure  = optional(bool, false)<br/><br/>    node_name                     = optional(string, "pve")<br/>    talos_disk_image_datastore_id = optional(string, "local")<br/>    template_datastore_id         = optional(string, "local-lvm")<br/>    vm_datastore_id               = optional(string, "local-lvm")<br/><br/>    dns_servers = optional(list(string), ["1.1.1.1", "8.8.8.8"])<br/><br/>    ccm_config = optional(object({<br/>      enabled    = bool<br/>      user       = optional(string, "talos-ccm@pve")<br/>      role       = optional(string, "TalosCCM")<br/>      token_name = optional(string, "ccm-token")<br/>      privileges = optional(list(string), ["VM.Audit"])<br/>      }), {<br/>      enabled    = true<br/>      user       = "talos-ccm@pve"<br/>      role       = "TalosCCM"<br/>      token_name = "ccm-token"<br/>      privileges = ["VM.Audit"]<br/>    })<br/>  })</pre> | n/a | yes |
| <a name="input_resource_config"></a> [resource\_config](#input\_resource\_config) | VM resource allocation configuration | <pre>object({<br/>    controlplane = optional(object({<br/>      memory    = optional(number, 4096)<br/>      cpu_cores = optional(number, 4)<br/>      disk_size = optional(number, 20)<br/>    }), {})<br/>    worker = optional(object({<br/>      memory    = optional(number, 8192)<br/>      cpu_cores = optional(number, 8)<br/>      disk_size = optional(number, 50)<br/>    }), {})<br/>    cpu_type = optional(string, "x86-64-v2-AES")<br/>  })</pre> | `{}` | no |
| <a name="input_tagging_config"></a> [tagging\_config](#input\_tagging\_config) | Tagging configuration for resources | <pre>object({<br/>    common = optional(list(string), ["talos", "terraform"])<br/>    extra  = optional(list(string), [])<br/>  })</pre> | <pre>{<br/>  "common": [<br/>    "talos",<br/>    "terraform"<br/>  ],<br/>  "extra": []<br/>}</pre> | no |
| <a name="input_talos_image_config"></a> [talos\_image\_config](#input\_talos\_image\_config) | Talos image configuration | <pre>object({<br/>    schematic_id = string<br/>    filename     = string<br/>  })</pre> | n/a | yes |
| <a name="input_template_config"></a> [template\_config](#input\_template\_config) | VM template configuration | <pre>object({<br/>    controlplane_id = optional(number, 998)<br/>    worker_id       = optional(number, 999)<br/>  })</pre> | `{}` | no |
| <a name="input_vm_id_ranges"></a> [vm\_id\_ranges](#input\_vm\_id\_ranges) | VM ID ranges for different node types | <pre>object({<br/>    controlplane_min = optional(number, 2000)<br/>    controlplane_max = optional(number, 2999)<br/>    worker_min       = optional(number, 3000)<br/>    worker_max       = optional(number, 3999)<br/>  })</pre> | `{}` | no |

## Outputs

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
