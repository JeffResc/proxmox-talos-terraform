# proxmox-talos-terraform

## Getting Started

### 1. Tofu Initialization

```bash
tofu init
```

### 2. Tofu Plan

```bash
tofu plan -out=tfplan
```

### 3. Tofu Apply

```bash
tofu apply tfplan
```

Once the apply is successful, you will have a Talos cluster running on Proxmox with the following components:

- 3 Control Plane nodes
- 3 Worker nodes

You must wait for the Talos machines to fully initialize. This can take a few minutes depending on your Proxmox environment and network speed. Once the cluster is up, you can proceed to export the Talos configuration and retrieve the `kubeconfig`.

### 4. Export Talos Configuration

After applying the Terraform configuration, export the Talos client configuration:

```sh
tofu output -raw talos_client_configuration > ~/.talos/config
```

### 5. Get Kubeconfig

Once the cluster is up, retrieve the kubeconfig to interact with Kubernetes:

```sh
tofu output -raw talos_cluster_kubeconfig > ~/.kube/talos_config
```

**Note:** The control plane node IPs are calculated using the `cidrhost()` function in Terraform. The first control plane node IP is the network base address plus `controlplane_ip_start`. For example:
- If `network_cidr = "192.168.100.0/24"` and `controlplane_ip_start = 10`
- Control plane nodes will be: 192.168.100.10, 192.168.100.11, 192.168.100.12, etc.

### 6. Verify Cluster Access

```sh
export KUBECONFIG=~/.kube/talos_config
kubectl cluster-info dump
kubectl get nodes
kubectl get pods -A
```

## Documentation

This project uses [terraform-docs](https://github.com/terraform-docs/terraform-docs) to generate documentation automatically.

<!-- BEGIN_TF_DOCS -->
### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_proxmox"></a> [proxmox](#requirement\_proxmox) | 0.79.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | ~> 3.1 |
| <a name="requirement_talos"></a> [talos](#requirement\_talos) | 0.8.1 |

### Providers

| Name | Version |
|------|---------|
| <a name="provider_proxmox"></a> [proxmox](#provider\_proxmox) | 0.79.0 |
| <a name="provider_random"></a> [random](#provider\_random) | 3.7.2 |
| <a name="provider_talos"></a> [talos](#provider\_talos) | 0.8.1 |

### Modules

No modules.

### Resources

| Name | Type |
|------|------|
| proxmox_virtual_environment_download_file.talos_image | resource |
| proxmox_virtual_environment_role.ccm | resource |
| proxmox_virtual_environment_user.ccm | resource |
| proxmox_virtual_environment_user_token.ccm | resource |
| proxmox_virtual_environment_vm.nodes | resource |
| proxmox_virtual_environment_vm.template | resource |
| random_integer.node_vm_id | resource |
| talos_cluster_kubeconfig.this | resource |
| talos_image_factory_schematic.this | resource |
| talos_machine_bootstrap.this | resource |
| talos_machine_configuration_apply.controlplane | resource |
| talos_machine_configuration_apply.worker | resource |
| talos_machine_secrets.this | resource |
| talos_image_factory_extensions_versions.this | data source |
| talos_machine_configuration.controlplane | data source |
| talos_machine_configuration.worker | data source |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cluster_endpoint"></a> [cluster\_endpoint](#input\_cluster\_endpoint) | Cluster endpoint URL | `string` | `"https://192.168.0.100:6443"` | no |
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
| <a name="input_enable_vip"></a> [enable\_vip](#input\_enable\_vip) | Enable VIP (Virtual IP) for controlplane nodes | `bool` | `true` | no |
| <a name="input_extra_tags"></a> [extra\_tags](#input\_extra\_tags) | Extra tags to add to resources | `list(string)` | `[]` | no |
| <a name="input_image_download_node"></a> [image\_download\_node](#input\_image\_download\_node) | Proxmox node where Talos disk images are downloaded | `string` | `"pve"` | no |
| <a name="input_network_bridge"></a> [network\_bridge](#input\_network\_bridge) | Network bridge for VM network interfaces | `string` | `"vmbr0"` | no |
| <a name="input_network_cidr"></a> [network\_cidr](#input\_network\_cidr) | Network CIDR for node IP addresses (ignored when enable\_dhcp is true) | `string` | n/a | yes |
| <a name="input_network_gateway"></a> [network\_gateway](#input\_network\_gateway) | Network gateway IP address (ignored when enable\_dhcp is true) | `string` | n/a | yes |
| <a name="input_network_interface"></a> [network\_interface](#input\_network\_interface) | Network interface name for node network configuration | `string` | `"eth0"` | no |
| <a name="input_node_distribution"></a> [node\_distribution](#input\_node\_distribution) | Distribution of VMs across Proxmox nodes | <pre>map(object({<br/>    controlplane_count = number<br/>    worker_count       = number<br/>  }))</pre> | <pre>{<br/>  "pve": {<br/>    "controlplane_count": 3,<br/>    "worker_count": 3<br/>  }<br/>}</pre> | no |
| <a name="input_proxmox_api_token"></a> [proxmox\_api\_token](#input\_proxmox\_api\_token) | Proxmox API token in format 'user@realm!tokenname=token-secret' | `string` | n/a | yes |
| <a name="input_proxmox_ccm_role"></a> [proxmox\_ccm\_role](#input\_proxmox\_ccm\_role) | Proxmox role for Cloud Controller Manager | `string` | `"TalosCCM"` | no |
| <a name="input_proxmox_ccm_user"></a> [proxmox\_ccm\_user](#input\_proxmox\_ccm\_user) | Proxmox user for Cloud Controller Manager | `string` | `"talos-ccm@pve"` | no |
| <a name="input_proxmox_endpoint"></a> [proxmox\_endpoint](#input\_proxmox\_endpoint) | n/a | `string` | `"https://your-proxmox:8006/"` | no |
| <a name="input_proxmox_insecure"></a> [proxmox\_insecure](#input\_proxmox\_insecure) | n/a | `bool` | `false` | no |
| <a name="input_talos_disk_image_datastore_id"></a> [talos\_disk\_image\_datastore\_id](#input\_talos\_disk\_image\_datastore\_id) | Datastore for downloading Talos disk images | `string` | `"local"` | no |
| <a name="input_talos_version"></a> [talos\_version](#input\_talos\_version) | n/a | `string` | `"v1.10.5"` | no |
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
| <a name="output_cluster_endpoint"></a> [cluster\_endpoint](#output\_cluster\_endpoint) | Cluster endpoint URL |
| <a name="output_controlplane_ips"></a> [controlplane\_ips](#output\_controlplane\_ips) | List of control plane IP addresses |
| <a name="output_controlplane_nodes"></a> [controlplane\_nodes](#output\_controlplane\_nodes) | Control plane node information |
| <a name="output_controlplane_template_id"></a> [controlplane\_template\_id](#output\_controlplane\_template\_id) | Control plane template VM ID |
| <a name="output_proxmox_ccm_token"></a> [proxmox\_ccm\_token](#output\_proxmox\_ccm\_token) | Proxmox Cloud Controller Manager API token |
| <a name="output_talos_client_configuration"></a> [talos\_client\_configuration](#output\_talos\_client\_configuration) | Complete Talos client configuration for ~/.talos/config |
| <a name="output_talos_cluster_kubeconfig"></a> [talos\_cluster\_kubeconfig](#output\_talos\_cluster\_kubeconfig) | Talos cluster kubeconfig |
| <a name="output_talos_image_id"></a> [talos\_image\_id](#output\_talos\_image\_id) | Talos image ID in Proxmox |
| <a name="output_talos_machine_secrets"></a> [talos\_machine\_secrets](#output\_talos\_machine\_secrets) | Talos machine secrets (sensitive) |
| <a name="output_worker_ips"></a> [worker\_ips](#output\_worker\_ips) | List of worker IP addresses |
| <a name="output_worker_nodes"></a> [worker\_nodes](#output\_worker\_nodes) | Worker node information |
| <a name="output_worker_template_id"></a> [worker\_template\_id](#output\_worker\_template\_id) | Worker template VM ID |
<!-- END_TF_DOCS -->
