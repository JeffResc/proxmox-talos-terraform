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
README.md updated successfully
<!-- END_TF_DOCS -->
