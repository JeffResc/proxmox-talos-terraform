# =============================================================================
# CLUSTER CONFIGURATION
# =============================================================================

variable "cluster_config" {
  description = "Cluster configuration settings"
  type = object({
    name          = string
    talos_version = optional(string)
    vip = optional(object({
      enabled = bool
      ip      = optional(string)
    }))
    endpoint_override = optional(string)
  })
}

# =============================================================================
# NETWORK CONFIGURATION
# =============================================================================

variable "network_config" {
  description = "Network configuration for the isolated cluster network"
  type = object({
    # Basic network settings (from root)
    enable_dhcp = optional(bool, false)
    cidr        = string
    gateway     = string
    bridge      = optional(string, "vmbr0")
    interface   = optional(string, "eth0")

    # VPC-like network settings
    create_bridge = optional(bool, true)
    bridge_name   = optional(string)       # Auto-generated if not specified
    bridge_id     = optional(number, 100)  # Used if bridge_name not specified
    bridge_cidr   = optional(string)       # CIDR for the bridge interface
    bridge_ports  = optional(list(string)) # Physical interfaces to bridge
    vlan_aware    = optional(bool, true)

    # VLAN configuration
    vlan_id               = optional(number) # Create VLAN if specified
    vlan_parent_interface = optional(string, "eth0")

    # Resource pool
    resource_pool_id = optional(string) # Defaults to cluster name

    # Network settings
    mtu = optional(number, 1500)

    # Firewall configuration
    enable_firewall = optional(bool, true)
    allowed_cidrs   = optional(list(string), ["0.0.0.0/0"])
    nodeport_range  = optional(string, "30000-32767")
  })

  validation {
    condition     = can(cidrhost(var.network_config.cidr, 0))
    error_message = "Network CIDR must be a valid CIDR notation."
  }

  validation {
    condition     = var.network_config.bridge_cidr == null || can(cidrhost(var.network_config.bridge_cidr, 0))
    error_message = "Bridge CIDR must be a valid CIDR notation if specified."
  }

  validation {
    condition     = var.network_config.vlan_id == null || (var.network_config.vlan_id >= 1 && var.network_config.vlan_id <= 4094)
    error_message = "VLAN ID must be between 1 and 4094."
  }

  validation {
    condition     = var.network_config.mtu >= 68 && var.network_config.mtu <= 65535
    error_message = "MTU must be between 68 and 65535."
  }
}

# =============================================================================
# NODE DISTRIBUTION
# =============================================================================

variable "node_distribution" {
  description = "Distribution of nodes across Proxmox hosts (used to determine where to create network resources)"
  type = map(object({
    controlplane_count = number
    worker_count       = number
  }))
  default = {
    "pve" = {
      controlplane_count = 3
      worker_count       = 3
    }
  }
}
