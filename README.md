# proxmox-talos-terraform

## Getting Started

### 1. Tofu Initialization

```bash
tofu -chdir=talos-template init
```

### 2. Tofu Plan

```bash
tofu -chdir=talos-template plan -out=tfplan
```

### 3. Tofu Apply

```bash
tofu -chdir=talos-template apply tfplan
```

Once the apply is successful, you will have a Talos cluster running on Proxmox with the following components:

- 3 Control Plane nodes
- 3 Worker nodes

You must wait for the Talos machines to fully initialize. This can take a few minutes depending on your Proxmox environment and network speed. Once the cluster is up, you can proceed to export the Talos configuration and retrieve the `kubeconfig`.

### 4. Export Talos Configuration

After applying the Terraform configuration, export the Talos client configuration:

```sh
tofu -chdir=talos-template output -raw talos_client_configuration > ~/.talos/config
```

### 5. Get Kubeconfig

Once the cluster is up, retrieve the kubeconfig to interact with Kubernetes. You must specify a control plane IP when issuing `talosctl` commands. You can specify any of the control plane node IPs to get the kubeconfig. The IPs are calculated based on the `network_cidr` and `controlplane_ip_start` variables defined in the Terraform configuration.

_Example_: The first control plane node IP is calculated from the network CIDR base + `controlplane_ip_start`. With `network_cidr="192.168.100.0/24"` and `controlplane_ip_start=10`, the first control plane node would be `192.168.100.10`.

```sh
# Check cluster health first (optional)
talosctl --context talos-cluster health -n 192.168.100.10

# Get and save the kubeconfig (specify a single control plane node)
talosctl --context talos-cluster kubeconfig ~/.kube/talos_config -n 192.168.100.10

# Or if you want to force overwrite existing kubeconfig
talosctl --context talos-cluster kubeconfig ~/.kube/talos_config -n 192.168.100.10 --force
```

**Note:** The control plane node IPs are calculated using the `cidrhost()` function in Terraform. The first control plane node IP is the network base address plus `controlplane_ip_start`. For example:
- If `network_cidr = "192.168.100.0/24"` and `controlplane_ip_start = 10`
- Control plane nodes will be: 192.168.100.10, 192.168.100.11, 192.168.100.12, etc.

### 6. Verify Cluster Access

```sh
export KUBECONFIG=~/.kube/talos_config
kubectl config use-context talos-cluster
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
| <a name="requirement_talos"></a> [talos](#requirement\_talos) | 0.9.0-alpha.0 |

### Providers

| Name | Version |
|------|---------|
| <a name="provider_proxmox"></a> [proxmox](#provider\_proxmox) | 0.79.0 |
| <a name="provider_talos"></a> [talos](#provider\_talos) | 0.9.0-alpha.0 |

### Modules

No modules.

### Resources

| Name | Type |
|------|------|
| [proxmox_virtual_environment_download_file.talos_image](https://registry.terraform.io/providers/bpg/proxmox/0.79.0/docs/resources/virtual_environment_download_file) | resource |
| [proxmox_virtual_environment_file.controlplane_cloud_init](https://registry.terraform.io/providers/bpg/proxmox/0.79.0/docs/resources/virtual_environment_file) | resource |
| [proxmox_virtual_environment_file.controlplane_node_cloud_init](https://registry.terraform.io/providers/bpg/proxmox/0.79.0/docs/resources/virtual_environment_file) | resource |
| [proxmox_virtual_environment_file.worker_cloud_init](https://registry.terraform.io/providers/bpg/proxmox/0.79.0/docs/resources/virtual_environment_file) | resource |
| [proxmox_virtual_environment_file.worker_node_cloud_init](https://registry.terraform.io/providers/bpg/proxmox/0.79.0/docs/resources/virtual_environment_file) | resource |
| [proxmox_virtual_environment_vm.controlplane_nodes](https://registry.terraform.io/providers/bpg/proxmox/0.79.0/docs/resources/virtual_environment_vm) | resource |
| [proxmox_virtual_environment_vm.controlplane_template](https://registry.terraform.io/providers/bpg/proxmox/0.79.0/docs/resources/virtual_environment_vm) | resource |
| [proxmox_virtual_environment_vm.worker_nodes](https://registry.terraform.io/providers/bpg/proxmox/0.79.0/docs/resources/virtual_environment_vm) | resource |
| [proxmox_virtual_environment_vm.worker_template](https://registry.terraform.io/providers/bpg/proxmox/0.79.0/docs/resources/virtual_environment_vm) | resource |
| [talos_image_factory_schematic.this](https://registry.terraform.io/providers/siderolabs/talos/0.9.0-alpha.0/docs/resources/image_factory_schematic) | resource |
| [talos_machine_bootstrap.this](https://registry.terraform.io/providers/siderolabs/talos/0.9.0-alpha.0/docs/resources/machine_bootstrap) | resource |
| [talos_machine_configuration_apply.controlplane](https://registry.terraform.io/providers/siderolabs/talos/0.9.0-alpha.0/docs/resources/machine_configuration_apply) | resource |
| [talos_machine_configuration_apply.worker](https://registry.terraform.io/providers/siderolabs/talos/0.9.0-alpha.0/docs/resources/machine_configuration_apply) | resource |
| [talos_machine_secrets.this](https://registry.terraform.io/providers/siderolabs/talos/0.9.0-alpha.0/docs/resources/machine_secrets) | resource |
| [talos_image_factory_extensions_versions.this](https://registry.terraform.io/providers/siderolabs/talos/0.9.0-alpha.0/docs/data-sources/image_factory_extensions_versions) | data source |
| [talos_machine_configuration.controlplane](https://registry.terraform.io/providers/siderolabs/talos/0.9.0-alpha.0/docs/data-sources/machine_configuration) | data source |
| [talos_machine_configuration.worker](https://registry.terraform.io/providers/siderolabs/talos/0.9.0-alpha.0/docs/data-sources/machine_configuration) | data source |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cluster_endpoint"></a> [cluster\_endpoint](#input\_cluster\_endpoint) | Cluster endpoint URL | `string` | n/a | yes |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | Name of the Talos cluster | `string` | `"talos-cluster"` | no |
| <a name="input_controlplane_count"></a> [controlplane\_count](#input\_controlplane\_count) | Number of control plane nodes | `number` | `3` | no |
| <a name="input_controlplane_ip_start"></a> [controlplane\_ip\_start](#input\_controlplane\_ip\_start) | Starting IP address for control plane nodes (last octet) | `number` | `50` | no |
| <a name="input_dns_servers"></a> [dns\_servers](#input\_dns\_servers) | List of DNS servers for Talos nodes | `list(string)` | <pre>[<br/>  "1.1.1.1",<br/>  "8.8.8.8",<br/>  "8.8.4.4"<br/>]</pre> | no |
| <a name="input_network_bridge"></a> [network\_bridge](#input\_network\_bridge) | Network bridge for VM network interfaces | `string` | `"vmbr0"` | no |
| <a name="input_network_cidr"></a> [network\_cidr](#input\_network\_cidr) | Network CIDR for node IP addresses | `string` | n/a | yes |
| <a name="input_network_gateway"></a> [network\_gateway](#input\_network\_gateway) | Network gateway IP address | `string` | n/a | yes |
| <a name="input_node_name"></a> [node\_name](#input\_node\_name) | n/a | `string` | `"pve"` | no |
| <a name="input_proxmox_api_token"></a> [proxmox\_api\_token](#input\_proxmox\_api\_token) | Proxmox API token in format 'user@realm!tokenname=token-secret' | `string` | n/a | yes |
| <a name="input_proxmox_endpoint"></a> [proxmox\_endpoint](#input\_proxmox\_endpoint) | n/a | `string` | `"https://your-proxmox:8006/"` | no |
| <a name="input_proxmox_insecure"></a> [proxmox\_insecure](#input\_proxmox\_insecure) | n/a | `bool` | `true` | no |
| <a name="input_proxmox_ssh_agent"></a> [proxmox\_ssh\_agent](#input\_proxmox\_ssh\_agent) | Use SSH agent for Proxmox SSH connection | `bool` | `false` | no |
| <a name="input_proxmox_ssh_private_key_path"></a> [proxmox\_ssh\_private\_key\_path](#input\_proxmox\_ssh\_private\_key\_path) | Path to SSH private key for Proxmox connection | `string` | n/a | yes |
| <a name="input_proxmox_ssh_username"></a> [proxmox\_ssh\_username](#input\_proxmox\_ssh\_username) | SSH username for Proxmox connection | `string` | `"root"` | no |
| <a name="input_snippets_datastore_id"></a> [snippets\_datastore\_id](#input\_snippets\_datastore\_id) | Datastore for cloud-init snippets | `string` | `"local"` | no |
| <a name="input_talos_disk_image_datastore_id"></a> [talos\_disk\_image\_datastore\_id](#input\_talos\_disk\_image\_datastore\_id) | Datastore for downloading Talos disk images | `string` | `"local"` | no |
| <a name="input_talos_version"></a> [talos\_version](#input\_talos\_version) | n/a | `string` | `"v1.10.5"` | no |
| <a name="input_template_datastore_id"></a> [template\_datastore\_id](#input\_template\_datastore\_id) | Datastore for VM template disks | `string` | `"local-lvm"` | no |
| <a name="input_vm_datastore_id"></a> [vm\_datastore\_id](#input\_vm\_datastore\_id) | Datastore for VM initialization and cloud-init | `string` | `"local-lvm"` | no |
| <a name="input_worker_count"></a> [worker\_count](#input\_worker\_count) | Number of worker nodes | `number` | `3` | no |
| <a name="input_worker_ip_start"></a> [worker\_ip\_start](#input\_worker\_ip\_start) | Starting IP address for worker nodes (last octet) | `number` | `70` | no |

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_cluster_endpoint"></a> [cluster\_endpoint](#output\_cluster\_endpoint) | Cluster endpoint URL |
| <a name="output_controlplane_ips"></a> [controlplane\_ips](#output\_controlplane\_ips) | List of control plane IP addresses |
| <a name="output_controlplane_nodes"></a> [controlplane\_nodes](#output\_controlplane\_nodes) | Control plane node information |
| <a name="output_controlplane_template_id"></a> [controlplane\_template\_id](#output\_controlplane\_template\_id) | Control plane template VM ID |
| <a name="output_talos_client_configuration"></a> [talos\_client\_configuration](#output\_talos\_client\_configuration) | Complete Talos client configuration for ~/.talos/config |
| <a name="output_talos_image_id"></a> [talos\_image\_id](#output\_talos\_image\_id) | Talos image ID in Proxmox |
| <a name="output_talos_machine_secrets"></a> [talos\_machine\_secrets](#output\_talos\_machine\_secrets) | Talos machine secrets (sensitive) |
| <a name="output_worker_ips"></a> [worker\_ips](#output\_worker\_ips) | List of worker IP addresses |
| <a name="output_worker_nodes"></a> [worker\_nodes](#output\_worker\_nodes) | Worker node information |
| <a name="output_worker_template_id"></a> [worker\_template\_id](#output\_worker\_template\_id) | Worker template VM ID |
<!-- END_TF_DOCS -->