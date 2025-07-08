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
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_proxmox"></a> [proxmox](#requirement\_proxmox) | 0.79.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | ~> 3.1 |
| <a name="requirement_talos"></a> [talos](#requirement\_talos) | 0.8.1 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_proxmox_ccm"></a> [proxmox\_ccm](#module\_proxmox\_ccm) | ./modules/proxmox-ccm | n/a |
| <a name="module_proxmox_infrastructure"></a> [proxmox\_infrastructure](#module\_proxmox\_infrastructure) | ./modules/proxmox-infrastructure | n/a |
| <a name="module_talos_bootstrap"></a> [talos\_bootstrap](#module\_talos\_bootstrap) | ./modules/talos-bootstrap | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cluster_config"></a> [cluster\_config](#input\_cluster\_config) | Cluster configuration settings | <pre>object({<br/>    name          = string<br/>    talos_version = optional(string, "v1.10.5") # renovate: datasource=github-releases depName=siderolabs/talos<br/>    vip = optional(object({<br/>      enabled = bool<br/>      ip      = optional(string)<br/>      }), {<br/>      enabled = true<br/>      ip      = null<br/>    })<br/>    endpoint_override = optional(string)<br/>  })</pre> | n/a | yes |
| <a name="input_network_config"></a> [network\_config](#input\_network\_config) | Network configuration for Talos nodes | <pre>object({<br/>    cidr      = string<br/>    gateway   = string<br/>    bridge    = optional(string, "vmbr0")<br/>    interface = optional(string, "eth0")<br/>  })</pre> | n/a | yes |
| <a name="input_node_config"></a> [node\_config](#input\_node\_config) | Node configuration for the cluster | <pre>object({<br/>    controlplane_count    = number<br/>    worker_count          = number<br/>    controlplane_ip_start = optional(number, 10)<br/>    worker_ip_start       = optional(number, 20)<br/>  })</pre> | <pre>{<br/>  "controlplane_count": 3,<br/>  "worker_count": 3<br/>}</pre> | no |
| <a name="input_proxmox_config"></a> [proxmox\_config](#input\_proxmox\_config) | Proxmox connection and infrastructure configuration | <pre>object({<br/>    endpoint  = string<br/>    api_token = string<br/>    insecure  = optional(bool, false)<br/><br/>    node_name                     = optional(string, "pve")<br/>    talos_disk_image_datastore_id = optional(string, "local")<br/>    template_datastore_id         = optional(string, "local-lvm")<br/>    vm_datastore_id               = optional(string, "local-lvm")<br/><br/>    dns_servers = optional(list(string), ["1.1.1.1", "8.8.8.8"])<br/>  })</pre> | n/a | yes |

## Outputs

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
