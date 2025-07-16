# =============================================================================
# RESOURCE POOL
# =============================================================================

resource "proxmox_virtual_environment_pool" "cluster" {
  comment = "Resource pool for ${var.cluster_config.name} Talos cluster"
  pool_id = var.network_config.resource_pool_id != null ? var.network_config.resource_pool_id : var.cluster_config.name
}

# =============================================================================
# LINUX BRIDGE
# =============================================================================

resource "proxmox_virtual_environment_network_linux_bridge" "cluster" {
  for_each = var.network_config.create_bridge ? var.node_distribution : {}

  node_name = each.key
  name      = var.network_config.bridge_name != null ? var.network_config.bridge_name : "vmbr${var.network_config.bridge_id}"

  comment = "${var.cluster_config.name} cluster network"

  # Network configuration
  address = var.network_config.bridge_cidr

  # Bridge settings
  vlan_aware = var.network_config.vlan_aware

  # Bridge ports (physical interfaces)
  ports = var.network_config.bridge_ports != null ? var.network_config.bridge_ports : []

  # MTU configuration
  mtu = var.network_config.mtu

  # Autostart the bridge
  autostart = true
}

# =============================================================================
# POST-BRIDGE ROUTING CONFIGURATION
# =============================================================================

resource "null_resource" "configure_routing" {
  for_each = var.network_config.create_bridge && var.network_config.enable_nat_gateway ? var.node_distribution : {}

  triggers = {
    bridge_name  = proxmox_virtual_environment_network_linux_bridge.cluster[each.key].name
    network_cidr = var.network_config.cidr
  }

  connection {
    type        = "ssh"
    host        = var.proxmox_config.ssh_host != null ? var.proxmox_config.ssh_host : split(":", replace(var.proxmox_config.endpoint, "https://", ""))[0]
    user        = var.proxmox_config.ssh_user
    password    = var.proxmox_config.ssh_password
    private_key = var.proxmox_config.ssh_private_key != null ? file(var.proxmox_config.ssh_private_key) : null
  }

  provisioner "remote-exec" {
    inline = [
      # Add route to access cluster network from Proxmox host
      "ip route add ${var.network_config.cidr} dev ${self.triggers.bridge_name} || true",

      # Make route persistent in /etc/network/interfaces
      "grep -q 'up ip route add ${var.network_config.cidr}' /etc/network/interfaces || sed -i '/iface ${self.triggers.bridge_name}/a\\        up ip route add ${var.network_config.cidr} dev ${self.triggers.bridge_name}' /etc/network/interfaces",

      # Reload networking to apply changes
      "systemctl reload networking || true"
    ]
  }

  depends_on = [
    proxmox_virtual_environment_network_linux_bridge.cluster
  ]
}

# =============================================================================
# VLAN (Optional)
# =============================================================================

resource "proxmox_virtual_environment_network_linux_vlan" "cluster" {
  for_each = var.network_config.vlan_id != null ? var.node_distribution : {}

  node_name = each.key
  name      = "vlan${var.network_config.vlan_id}"

  comment   = "${var.cluster_config.name} cluster VLAN"
  interface = var.network_config.vlan_parent_interface
  vlan      = var.network_config.vlan_id

  # MTU configuration
  mtu = var.network_config.mtu

  # Autostart the VLAN
  autostart = true
}

# =============================================================================
# FIREWALL RULES (Optional)
# =============================================================================

# Cluster-level firewall configuration
resource "proxmox_virtual_environment_cluster_firewall" "config" {
  count = var.network_config.enable_firewall ? 1 : 0

  enabled = true

  # Allow established connections
  input_policy  = "DROP"
  output_policy = "ACCEPT"
}

# Firewall security group for Talos nodes
resource "proxmox_virtual_environment_cluster_firewall_security_group" "talos" {
  count = var.network_config.enable_firewall ? 1 : 0

  name    = "${var.cluster_config.name}-talos"
  comment = "Security group for ${var.cluster_config.name} Talos cluster"

  # Talos API (control plane)
  rule {
    type    = "in"
    action  = "ACCEPT"
    comment = "Talos API"
    dest    = var.network_config.cidr
    dport   = "50000"
    proto   = "tcp"
    source  = join(",", var.network_config.allowed_cidrs)
  }

  # Kubernetes API
  rule {
    type    = "in"
    action  = "ACCEPT"
    comment = "Kubernetes API"
    dest    = var.network_config.cidr
    dport   = "6443"
    proto   = "tcp"
    source  = join(",", var.network_config.allowed_cidrs)
  }

  # etcd peers (control plane to control plane)
  rule {
    type    = "in"
    action  = "ACCEPT"
    comment = "etcd peers"
    dest    = var.network_config.cidr
    dport   = "2379-2380"
    proto   = "tcp"
    source  = var.network_config.cidr
  }

  # Kubelet API (all nodes)
  rule {
    type    = "in"
    action  = "ACCEPT"
    comment = "Kubelet API"
    dest    = var.network_config.cidr
    dport   = "10250"
    proto   = "tcp"
    source  = var.network_config.cidr
  }

  # Talos API (node to node)
  rule {
    type    = "in"
    action  = "ACCEPT"
    comment = "Talos API internal"
    dest    = var.network_config.cidr
    dport   = "50001"
    proto   = "tcp"
    source  = var.network_config.cidr
  }

  # Allow all traffic between cluster nodes
  rule {
    type    = "in"
    action  = "ACCEPT"
    comment = "Cluster internal traffic"
    dest    = var.network_config.cidr
    source  = var.network_config.cidr
  }

  # NodePort Services (optional)
  dynamic "rule" {
    for_each = var.network_config.nodeport_range != null ? [1] : []
    content {
      type    = "in"
      action  = "ACCEPT"
      comment = "NodePort services"
      dest    = var.network_config.cidr
      dport   = var.network_config.nodeport_range
      proto   = "tcp"
      source  = join(",", var.network_config.allowed_cidrs)
    }
  }
}
