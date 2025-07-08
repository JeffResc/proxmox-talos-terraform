# homelab

## Getting Started

### 1. Export Talos Configuration

After applying the Terraform configuration, export the Talos client configuration:

```sh
tofu output -raw talos_client_configuration > ~/.talos/config
```

### 2. Get Kubeconfig

Once the cluster is up, retrieve the kubeconfig to interact with Kubernetes:

```sh
# Check cluster health first (optional)
talosctl --context talos-cluster health -n 192.168.100.10

# Get and save the kubeconfig (specify a single control plane node)
talosctl --context talos-cluster kubeconfig ~/.kube/talos_config -n 192.168.100.10

# Or if you want to force overwrite existing kubeconfig
talosctl --context talos-cluster kubeconfig ~/.kube/talos_config -n 192.168.100.10 --force
```

### 3. Verify Cluster Access

```sh
kubectl get nodes
kubectl get pods -A
```
