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
    host        = var.proxmox_config.host
    user        = var.proxmox_config.ssh_config != null ? var.proxmox_config.ssh_config.ssh_user : "root"
    private_key = var.proxmox_config.ssh_config != null ? file(var.proxmox_config.ssh_config.ssh_private_key) : null
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
# FIREWALL IPSETS (Optional)
# =============================================================================

# Create IPsets for organized network access control
resource "proxmox_virtual_environment_firewall_ipset" "cluster" {
  for_each = var.network_config.enable_firewall ? var.network_config.ipsets : {}

  name    = "${var.cluster_config.name}-${each.key}"
  comment = each.value.comment != null ? each.value.comment : "IPset for ${var.cluster_config.name} cluster - ${each.key}"

  dynamic "cidr" {
    for_each = each.value.cidrs
    content {
      name    = cidr.value
      comment = "Network ${cidr.value}"
    }
  }
}

# Always create cluster internal IPset for node-to-node communication
resource "proxmox_virtual_environment_firewall_ipset" "cluster_internal" {
  count = var.network_config.enable_firewall ? 1 : 0

  name    = "${var.cluster_config.name}-internal"
  comment = "Internal cluster network for ${var.cluster_config.name}"

  cidr {
    name    = var.network_config.cidr
    comment = "Cluster internal network"
  }
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

  # Talos API (control plane) - using IPsets for admin access
  dynamic "rule" {
    for_each = var.network_config.ipsets
    content {
      type    = "in"
      action  = "ACCEPT"
      comment = "Talos API - ${rule.key}"
      dest    = "+${proxmox_virtual_environment_firewall_ipset.cluster_internal[0].name}"
      dport   = "50000"
      proto   = "tcp"
      source  = "+${proxmox_virtual_environment_firewall_ipset.cluster[rule.key].name}"
    }
  }

  # Kubernetes API - using IPsets for admin access
  dynamic "rule" {
    for_each = var.network_config.ipsets
    content {
      type    = "in"
      action  = "ACCEPT"
      comment = "Kubernetes API - ${rule.key}"
      dest    = "+${proxmox_virtual_environment_firewall_ipset.cluster_internal[0].name}"
      dport   = "6443"
      proto   = "tcp"
      source  = "+${proxmox_virtual_environment_firewall_ipset.cluster[rule.key].name}"
    }
  }

  # etcd peers (control plane to control plane)
  rule {
    type    = "in"
    action  = "ACCEPT"
    comment = "etcd peers"
    dest    = "+${proxmox_virtual_environment_firewall_ipset.cluster_internal[0].name}"
    dport   = "2379-2380"
    proto   = "tcp"
    source  = "+${proxmox_virtual_environment_firewall_ipset.cluster_internal[0].name}"
  }

  # Kubelet API (all nodes)
  rule {
    type    = "in"
    action  = "ACCEPT"
    comment = "Kubelet API"
    dest    = "+${proxmox_virtual_environment_firewall_ipset.cluster_internal[0].name}"
    dport   = "10250"
    proto   = "tcp"
    source  = "+${proxmox_virtual_environment_firewall_ipset.cluster_internal[0].name}"
  }

  # Talos API (node to node)
  rule {
    type    = "in"
    action  = "ACCEPT"
    comment = "Talos API internal"
    dest    = "+${proxmox_virtual_environment_firewall_ipset.cluster_internal[0].name}"
    dport   = "50001"
    proto   = "tcp"
    source  = "+${proxmox_virtual_environment_firewall_ipset.cluster_internal[0].name}"
  }

  # Allow all traffic between cluster nodes
  rule {
    type    = "in"
    action  = "ACCEPT"
    comment = "Cluster internal traffic"
    dest    = "+${proxmox_virtual_environment_firewall_ipset.cluster_internal[0].name}"
    source  = "+${proxmox_virtual_environment_firewall_ipset.cluster_internal[0].name}"
  }

  # NodePort Services (optional) - using IPsets for admin access
  dynamic "rule" {
    for_each = var.network_config.nodeport_range != null ? var.network_config.ipsets : {}
    content {
      type    = "in"
      action  = "ACCEPT"
      comment = "NodePort services - ${rule.key}"
      dest    = "+${proxmox_virtual_environment_firewall_ipset.cluster_internal[0].name}"
      dport   = var.network_config.nodeport_range
      proto   = "tcp"
      source  = "+${proxmox_virtual_environment_firewall_ipset.cluster[rule.key].name}"
    }
  }
}
