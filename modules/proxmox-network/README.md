<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_null"></a> [null](#requirement\_null) | ~> 3.1 |
| <a name="requirement_proxmox"></a> [proxmox](#requirement\_proxmox) | 0.79.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_null"></a> [null](#provider\_null) | 3.2.4 |
| <a name="provider_proxmox"></a> [proxmox](#provider\_proxmox) | 0.79.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [null_resource.configure_routing](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [proxmox_virtual_environment_cluster_firewall.config](https://registry.terraform.io/providers/bpg/proxmox/0.79.0/docs/resources/virtual_environment_cluster_firewall) | resource |
| [proxmox_virtual_environment_cluster_firewall_security_group.talos](https://registry.terraform.io/providers/bpg/proxmox/0.79.0/docs/resources/virtual_environment_cluster_firewall_security_group) | resource |
| [proxmox_virtual_environment_network_linux_bridge.cluster](https://registry.terraform.io/providers/bpg/proxmox/0.79.0/docs/resources/virtual_environment_network_linux_bridge) | resource |
| [proxmox_virtual_environment_network_linux_vlan.cluster](https://registry.terraform.io/providers/bpg/proxmox/0.79.0/docs/resources/virtual_environment_network_linux_vlan) | resource |
| [proxmox_virtual_environment_pool.cluster](https://registry.terraform.io/providers/bpg/proxmox/0.79.0/docs/resources/virtual_environment_pool) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cluster_config"></a> [cluster\_config](#input\_cluster\_config) | Cluster configuration settings | <pre>object({<br/>    name          = string<br/>    talos_version = optional(string)<br/>    vip = optional(object({<br/>      enabled = bool<br/>      ip      = optional(string)<br/>    }))<br/>    endpoint_override = optional(string)<br/>  })</pre> | n/a | yes |
| <a name="input_network_config"></a> [network\_config](#input\_network\_config) | Network configuration for the isolated cluster network | <pre>object({<br/>    # Basic network settings (from root)<br/>    enable_dhcp = optional(bool, false)<br/>    cidr        = string<br/>    gateway     = string<br/>    bridge      = optional(string, "vmbr0")<br/>    interface   = optional(string, "eth0")<br/><br/>    # VPC-like network settings<br/>    create_bridge = optional(bool, true)<br/>    bridge_name   = optional(string)       # Auto-generated if not specified<br/>    bridge_id     = optional(number, 100)  # Used if bridge_name not specified<br/>    bridge_cidr   = optional(string)       # CIDR for the bridge interface<br/>    bridge_ports  = optional(list(string)) # Physical interfaces to bridge<br/>    vlan_aware    = optional(bool, true)<br/><br/>    # VLAN configuration<br/>    vlan_id               = optional(number) # Create VLAN if specified<br/>    vlan_parent_interface = optional(string, "eth0")<br/><br/>    # Resource pool<br/>    resource_pool_id = optional(string) # Defaults to cluster name<br/><br/>    # Network settings<br/>    mtu = optional(number, 1500)<br/><br/>    # Firewall configuration<br/>    enable_firewall = optional(bool, true)<br/>    allowed_cidrs   = optional(list(string), ["0.0.0.0/0"])<br/>    nodeport_range  = optional(string, "30000-32767")<br/><br/>    # NAT Gateway configuration<br/>    enable_nat_gateway = optional(bool, false) # Auto-configure routing for NAT<br/>  })</pre> | n/a | yes |
| <a name="input_node_distribution"></a> [node\_distribution](#input\_node\_distribution) | Distribution of nodes across Proxmox hosts (used to determine where to create network resources) | <pre>map(object({<br/>    controlplane_count = number<br/>    worker_count       = number<br/>  }))</pre> | <pre>{<br/>  "pve": {<br/>    "controlplane_count": 3,<br/>    "worker_count": 3<br/>  }<br/>}</pre> | no |
| <a name="input_proxmox_config"></a> [proxmox\_config](#input\_proxmox\_config) | Proxmox configuration including SSH access for routing setup | <pre>object({<br/>    endpoint  = string<br/>    api_token = optional(string)<br/>    insecure  = optional(bool, false)<br/><br/>    # SSH configuration for routing setup (optional)<br/>    ssh_host        = optional(string) # Defaults to endpoint host<br/>    ssh_user        = optional(string, "root")<br/>    ssh_password    = optional(string)<br/>    ssh_private_key = optional(string) # Path to SSH private key<br/>  })</pre> | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_bridge_name"></a> [bridge\_name](#output\_bridge\_name) | Name of the Linux bridge (either existing or created) |
| <a name="output_network_cidr"></a> [network\_cidr](#output\_network\_cidr) | CIDR of the cluster network |
| <a name="output_network_configuration"></a> [network\_configuration](#output\_network\_configuration) | Complete network configuration for use by other modules |
| <a name="output_resource_pool_id"></a> [resource\_pool\_id](#output\_resource\_pool\_id) | ID of the created resource pool |
| <a name="output_security_group_name"></a> [security\_group\_name](#output\_security\_group\_name) | Name of the firewall security group if created |
| <a name="output_vlan_id"></a> [vlan\_id](#output\_vlan\_id) | VLAN ID if VLAN was created |
<!-- END_TF_DOCS -->
