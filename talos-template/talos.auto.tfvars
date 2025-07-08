# Proxmox Connection
proxmox_endpoint = "https://192.168.100.1:8006/"
proxmox_insecure = true  # Using valid SSL certificate via Caddy proxy

# Proxmox Authentication
proxmox_api_token            = "terraform-prov@pve!token=084d5705-6e65-4835-8594-558b7fba459c"
proxmox_ssh_agent            = true
proxmox_ssh_username         = "root"
proxmox_ssh_private_key_path = "~/.ssh/id_proxmox"

# Proxmox Infrastructure
node_name                     = "pve"          # Update if your Proxmox node has a different name
talos_disk_image_datastore_id = "local"        # For ISO/image downloads
template_datastore_id         = "local-lvm"    # For VM template storage
snippets_datastore_id         = "local"        # IMPORTANT: This datastore must support snippets - see README
vm_datastore_id              = "local-lvm"     # For VM disks

# Talos Version
talos_version = "v1.10.5"  # Latest stable as of the codebase

# Cluster Configuration
cluster_name     = "talos-cluster"
cluster_endpoint = "https://192.168.100.100:6443"  # Cluster VIP on same network

# Node Counts
controlplane_count = 3  # 3 nodes for HA quorum
worker_count      = 3   # 3 worker nodes

# Network Configuration - Using the 192.168.100.0/24 network (Proxmox network)
network_cidr    = "192.168.100.0/24"  # Using the Proxmox network
network_gateway = "192.168.100.1"     # Your Proxmox host as gateway

# IP Allocation
controlplane_ip_start = 10  # Control planes: 192.168.100.10, 192.168.100.11, 192.168.100.12
worker_ip_start      = 20  # Workers: 192.168.100.20, 192.168.100.21, 192.168.100.22

# DNS Configuration
dns_servers = [
  "192.168.1.1",  # Your Proxmox host (if running DNS)
  "1.1.1.1",        # Cloudflare DNS primary
  "8.8.8.8"         # Google DNS as fallback
]