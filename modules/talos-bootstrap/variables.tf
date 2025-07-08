variable "talos_version" {
  description = "Version of Talos Linux to use"
  type        = string
  default     = "v1.10.5" # renovate: datasource=github-releases depName=siderolabs/talos
}

variable "cluster_name" {
  description = "Name of the Talos cluster"
  type        = string
  default     = "talos"
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

variable "cluster_vip_enabled" {
  description = "Enable VIP (Virtual IP) for cluster endpoint. When true, cluster_vip_ip is used as the cluster endpoint."
  type        = bool
  default     = true
}

variable "cluster_vip_ip" {
  description = "IP address for the cluster VIP (Virtual IP). Required when cluster_vip_enabled is true."
  type        = string
  default     = null
  validation {
    condition     = var.cluster_vip_ip == null || can(regex("^(?:[0-9]{1,3}\\.){3}[0-9]{1,3}$", var.cluster_vip_ip))
    error_message = "Cluster VIP IP must be a valid IPv4 address."
  }
  validation {
    condition     = !var.cluster_vip_enabled || var.cluster_vip_ip != null
    error_message = "cluster_vip_ip must be provided when cluster_vip_enabled is true."
  }
}

variable "network_interface" {
  description = "Network interface name for node network configuration"
  type        = string
  default     = "eth0"
}

variable "enable_dhcp" {
  description = "Enable DHCP for node network interfaces. When true, static IP variables are ignored"
  type        = bool
  default     = false
}

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

variable "ccm_token_id" {
  description = "Proxmox CCM token ID"
  type        = string
}

variable "ccm_token_secret" {
  description = "Proxmox CCM token secret"
  type        = string
  sensitive   = true
}

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