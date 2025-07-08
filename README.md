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

No providers.

### Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_proxmox_ccm"></a> [proxmox\_ccm](#module\_proxmox\_ccm) | ./modules/proxmox-ccm | n/a |
| <a name="module_proxmox_infrastructure"></a> [proxmox\_infrastructure](#module\_proxmox\_infrastructure) | ./modules/proxmox-infrastructure | n/a |
| <a name="module_talos_bootstrap"></a> [talos\_bootstrap](#module\_talos\_bootstrap) | ./modules/talos-bootstrap | n/a |

### Resources

No resources.

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cluster_endpoint_override"></a> [cluster\_endpoint\_override](#input\_cluster\_endpoint\_override) | Custom cluster endpoint URL. Only used when cluster\_vip\_enabled is false. Must include protocol and port. | `string` | `null` | no |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | Name of the Talos cluster | `string` | `"talos"` | no |
| <a name="input_cluster_vip_enabled"></a> [cluster\_vip\_enabled](#input\_cluster\_vip\_enabled) | Enable VIP (Virtual IP) for cluster endpoint. When true, cluster\_vip\_ip is used as the cluster endpoint. | `bool` | `true` | no |
| <a name="input_cluster_vip_ip"></a> [cluster\_vip\_ip](#input\_cluster\_vip\_ip) | IP address for the cluster VIP (Virtual IP). Required when cluster\_vip\_enabled is true. | `string` | `null` | no |
| <a name="input_network_cidr"></a> [network\_cidr](#input\_network\_cidr) | Network CIDR for node IP addresses (ignored when enable\_dhcp is true) | `string` | n/a | yes |
| <a name="input_network_gateway"></a> [network\_gateway](#input\_network\_gateway) | Network gateway IP address (ignored when enable\_dhcp is true) | `string` | n/a | yes |
| <a name="input_network_interface"></a> [network\_interface](#input\_network\_interface) | Network interface name for node network configuration | `string` | `"eth0"` | no |
| <a name="input_proxmox_api_token"></a> [proxmox\_api\_token](#input\_proxmox\_api\_token) | Proxmox API token in format 'user@realm!tokenname=token-secret' | `string` | n/a | yes |
| <a name="input_proxmox_endpoint"></a> [proxmox\_endpoint](#input\_proxmox\_endpoint) | Proxmox Virtual Environment API endpoint URL | `string` | `"https://your-proxmox:8006/"` | no |
| <a name="input_proxmox_insecure"></a> [proxmox\_insecure](#input\_proxmox\_insecure) | Skip TLS certificate verification for Proxmox API | `bool` | `false` | no |
| <a name="input_talos_version"></a> [talos\_version](#input\_talos\_version) | Version of Talos Linux to use | `string` | `"v1.10.5"` | no |

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
