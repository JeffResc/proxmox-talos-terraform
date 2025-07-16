# =============================================================================
# PROXMOX CONFIGURATION
# =============================================================================

variable "proxmox_config" {
  description = "Proxmox connection and infrastructure configuration"
  type = object({
    host      = string
    port      = optional(number, 8006)
    api_token = string
    insecure  = optional(bool, false)

    node_name                     = optional(string, "pve")
    talos_disk_image_datastore_id = optional(string, "local")
    template_datastore_id         = optional(string, "local-lvm")
    vm_datastore_id               = optional(string, "local-lvm")

    dns_servers = optional(list(string), ["1.1.1.1", "8.8.8.8"])

    # SSH configuration for routing setup (optional)
    ssh_config = optional(object({
      ssh_user        = optional(string, "root")
      ssh_private_key = string # Path to SSH private key (required for NAT gateway)
    }))

    ccm_config = optional(object({
      enabled    = bool
      user       = optional(string, "talos-ccm@pve")
      role       = optional(string, "TalosCCM")
      token_name = optional(string, "ccm-token")
      privileges = optional(list(string), ["VM.Audit"])
      }), {
      enabled    = true
      user       = "talos-ccm@pve"
      role       = "TalosCCM"
      token_name = "ccm-token"
      privileges = ["VM.Audit"]
    })
  })
  sensitive = true
  validation {
    condition     = can(regex("^[a-zA-Z0-9][a-zA-Z0-9.-]*[a-zA-Z0-9]$", var.proxmox_config.host)) || can(regex("^([0-9]{1,3}\\.){3}[0-9]{1,3}$", var.proxmox_config.host))
    error_message = "Proxmox host must be a valid hostname or IP address"
  }
  validation {
    condition     = var.proxmox_config.port > 0 && var.proxmox_config.port <= 65535
    error_message = "Proxmox port must be between 1 and 65535"
  }
}

# =============================================================================
# NETWORK CONFIGURATION
# =============================================================================

variable "network_config" {
  description = "Network configuration for Talos nodes"
  type = object({
    enable_dhcp = optional(bool, false)
    cidr        = string
    gateway     = string
    bridge      = optional(string, "vmbr0")
    interface   = optional(string, "eth0")
  })
  validation {
    condition     = can(cidrhost(var.network_config.cidr, 0))
    error_message = "Network CIDR must be a valid CIDR notation."
  }
}

# =============================================================================
# CLUSTER CONFIGURATION
# =============================================================================

variable "cluster_config" {
  description = "Cluster configuration settings"
  type = object({
    name          = string
    talos_version = optional(string, "v1.10.5") # renovate: datasource=github-releases depName=siderolabs/talos
    vip = optional(object({
      enabled = bool
      ip      = optional(string)
      }), {
      enabled = true
      ip      = null
    })
    endpoint_override = optional(string)
  })
  validation {
    condition = (
      !var.cluster_config.vip.enabled ||
      (var.cluster_config.vip.enabled && var.cluster_config.vip.ip != null)
    )
    error_message = "VIP IP must be provided when VIP is enabled."
  }
  validation {
    condition = (
      var.cluster_config.vip.enabled ||
      (!var.cluster_config.vip.enabled && var.cluster_config.endpoint_override != null)
    )
    error_message = "endpoint_override must be provided when VIP is disabled."
  }
  validation {
    condition = (
      var.cluster_config.vip.ip == null ||
      can(regex("^(?:[0-9]{1,3}\\.){3}[0-9]{1,3}$", var.cluster_config.vip.ip))
    )
    error_message = "VIP IP must be a valid IPv4 address."
  }
  validation {
    condition = (
      var.cluster_config.endpoint_override == null ||
      can(regex("^https?://", var.cluster_config.endpoint_override))
    )
    error_message = "Cluster endpoint override must be a valid URL starting with http:// or https://"
  }
}

# =============================================================================
# NODE INPUTS FROM INFRASTRUCTURE MODULE
# =============================================================================

variable "controlplane_nodes" {
  description = "Map of controlplane nodes with their endpoints and VM IDs"
  type = map(object({
    endpoint = string
    node     = string
    vm_id    = string
  }))
}

variable "worker_nodes" {
  description = "Map of worker nodes with their endpoints and VM IDs"
  type = map(object({
    endpoint = string
    node     = string
    vm_id    = string
  }))
}

variable "first_controlplane_endpoint" {
  description = "Endpoint of the first controlplane node"
  type        = string
}

variable "first_controlplane_node" {
  description = "Node address of the first controlplane node"
  type        = string
}

variable "nodes_ready" {
  description = "Dependency variable to ensure nodes are ready"
  type        = any
  default     = null
}
