variable "proxmox_config" {
  description = "Proxmox connection and infrastructure configuration"
  type = object({
    endpoint  = string
    api_token = string
    insecure  = optional(bool, false)

    node_name                     = optional(string, "pve")
    talos_disk_image_datastore_id = optional(string, "local")
    template_datastore_id         = optional(string, "local-lvm")
    vm_datastore_id               = optional(string, "local-lvm")

    dns_servers = optional(list(string), ["1.1.1.1", "8.8.8.8"])
  })
  sensitive = true
  validation {
    condition     = can(regex("^https?://", var.proxmox_config.endpoint))
    error_message = "Proxmox endpoint must be a valid URL starting with http:// or https://"
  }
}

variable "network_config" {
  description = "Network configuration for Talos nodes"
  type = object({
    cidr      = string
    gateway   = string
    bridge    = optional(string, "vmbr0")
    interface = optional(string, "eth0")
  })
  validation {
    condition     = can(cidrhost(var.network_config.cidr, 0))
    error_message = "Network CIDR must be a valid CIDR notation."
  }
}

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

variable "node_config" {
  description = "Node configuration for the cluster"
  type = object({
    controlplane_count    = number
    worker_count          = number
    controlplane_ip_start = optional(number, 10)
    worker_ip_start       = optional(number, 20)
  })
  default = {
    controlplane_count = 3
    worker_count       = 3
  }
  validation {
    condition     = var.node_config.controlplane_count % 2 == 1 && var.node_config.controlplane_count >= 1
    error_message = "Control plane count must be an odd number (1, 3, 5, etc.) for etcd quorum."
  }
  validation {
    condition     = var.node_config.worker_count >= 0
    error_message = "Worker count must be 0 or greater."
  }
}
