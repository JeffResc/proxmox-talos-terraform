# Root-level variables for values that need to be shared across modules
# or have no reasonable defaults

variable "proxmox_api_token" {
  description = "Proxmox API token in format 'user@realm!tokenname=token-secret'"
  type        = string
  sensitive   = true
}

# Network configuration - required for static IP setup
variable "network_cidr" {
  description = "Network CIDR for node IP addresses (ignored when enable_dhcp is true)"
  type        = string
  validation {
    condition     = can(cidrhost(var.network_cidr, 0))
    error_message = "Network CIDR must be a valid CIDR notation."
  }
}

variable "network_gateway" {
  description = "Network gateway IP address (ignored when enable_dhcp is true)"
  type        = string
}

# VIP configuration - required when VIP is enabled
variable "cluster_vip_ip" {
  description = "IP address for the cluster VIP (Virtual IP). Required when cluster_vip_enabled is true."
  type        = string
  default     = null
  validation {
    condition     = var.cluster_vip_ip == null || can(regex("^(?:[0-9]{1,3}\\.){3}[0-9]{1,3}$", var.cluster_vip_ip))
    error_message = "Cluster VIP IP must be a valid IPv4 address."
  }
}

# Talos version - needs to be consistent across modules
variable "talos_version" {
  description = "Version of Talos Linux to use"
  type        = string
  default     = "v1.10.5" # renovate: datasource=github-releases depName=siderolabs/talos
}

# Proxmox connection settings
variable "proxmox_endpoint" {
  description = "Proxmox Virtual Environment API endpoint URL"
  type        = string
  default     = "https://your-proxmox:8006/"
}

variable "proxmox_insecure" {
  description = "Skip TLS certificate verification for Proxmox API"
  type        = bool
  default     = false
}

# Cluster configuration
variable "cluster_name" {
  description = "Name of the Talos cluster"
  type        = string
  default     = "talos"
}

variable "cluster_vip_enabled" {
  description = "Enable VIP (Virtual IP) for cluster endpoint. When true, cluster_vip_ip is used as the cluster endpoint."
  type        = bool
  default     = true
}

variable "cluster_endpoint_override" {
  description = "Custom cluster endpoint URL. Only used when cluster_vip_enabled is false. Must include protocol and port."
  type        = string
  default     = null
  validation {
    condition     = var.cluster_endpoint_override == null || can(regex("^https?://", var.cluster_endpoint_override))
    error_message = "Cluster endpoint override must be a valid URL starting with http:// or https://"
  }
  validation {
    condition     = var.cluster_vip_enabled || var.cluster_endpoint_override != null
    error_message = "cluster_endpoint_override must be provided when cluster_vip_enabled is false"
  }
}

# Network interface for outputs
variable "network_interface" {
  description = "Network interface name for node network configuration"
  type        = string
  default     = "eth0"
}