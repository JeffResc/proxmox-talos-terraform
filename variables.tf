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
    condition     = can(regex("^https?://", var.proxmox_config.endpoint))
    error_message = "Proxmox endpoint must be a valid URL starting with http:// or https://"
  }
}

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

# =============================================================================
# VM TEMPLATE CONFIGURATION
# =============================================================================

variable "template_config" {
  description = "VM template configuration"
  type = object({
    controlplane_id = optional(number, 998)
    worker_id       = optional(number, 999)
    node            = optional(string, "pve")
  })
  default = {}
  validation {
    condition     = var.template_config.controlplane_id > 0 && var.template_config.controlplane_id < 10000
    error_message = "Control plane template ID must be between 1 and 9999."
  }
  validation {
    condition     = var.template_config.worker_id > 0 && var.template_config.worker_id < 10000
    error_message = "Worker template ID must be between 1 and 9999."
  }
}

# =============================================================================
# VM RESOURCE CONFIGURATION
# =============================================================================

variable "resource_config" {
  description = "VM resource allocation configuration"
  type = object({
    controlplane = optional(object({
      memory    = optional(number, 4096)
      cpu_cores = optional(number, 4)
      disk_size = optional(number, 20)
    }), {})
    worker = optional(object({
      memory    = optional(number, 8192)
      cpu_cores = optional(number, 8)
      disk_size = optional(number, 50)
    }), {})
    cpu_type = optional(string, "x86-64-v2-AES")
  })
  default = {}
  validation {
    condition     = var.resource_config.controlplane.memory >= 2048
    error_message = "Control plane memory must be at least 2048 MB."
  }
  validation {
    condition     = var.resource_config.worker.memory >= 2048
    error_message = "Worker memory must be at least 2048 MB."
  }
  validation {
    condition     = var.resource_config.controlplane.cpu_cores >= 2
    error_message = "Control plane CPU cores must be at least 2."
  }
  validation {
    condition     = var.resource_config.worker.cpu_cores >= 2
    error_message = "Worker CPU cores must be at least 2."
  }
  validation {
    condition     = var.resource_config.controlplane.disk_size >= 10
    error_message = "Control plane disk size must be at least 10 GB."
  }
  validation {
    condition     = var.resource_config.worker.disk_size >= 20
    error_message = "Worker disk size must be at least 20 GB."
  }
}

# =============================================================================
# VM ID RANGES
# =============================================================================

variable "vm_id_ranges" {
  description = "VM ID ranges for different node types"
  type = object({
    controlplane_min = optional(number, 2000)
    controlplane_max = optional(number, 2999)
    worker_min       = optional(number, 3000)
    worker_max       = optional(number, 3999)
  })
  default = {}
  validation {
    condition     = var.vm_id_ranges.controlplane_min > 0 && var.vm_id_ranges.controlplane_min < 9999
    error_message = "Control plane VM ID min must be between 1 and 9998."
  }
  validation {
    condition     = var.vm_id_ranges.controlplane_max > 0 && var.vm_id_ranges.controlplane_max < 10000
    error_message = "Control plane VM ID max must be between 1 and 9999."
  }
  validation {
    condition     = var.vm_id_ranges.worker_min > 0 && var.vm_id_ranges.worker_min < 9999
    error_message = "Worker VM ID min must be between 1 and 9998."
  }
  validation {
    condition     = var.vm_id_ranges.worker_max > 0 && var.vm_id_ranges.worker_max < 10000
    error_message = "Worker VM ID max must be between 1 and 9999."
  }
}

# =============================================================================
# PROXMOX INFRASTRUCTURE CONFIGURATION
# =============================================================================

variable "node_distribution" {
  description = "Distribution of VMs across Proxmox nodes"
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
  validation {
    condition = alltrue([
      for node_name, config in var.node_distribution :
      config.controlplane_count >= 0 && config.worker_count >= 0
    ])
    error_message = "Node counts must be zero or positive."
  }
  validation {
    condition = sum([
      for node_name, config in var.node_distribution : config.controlplane_count
      ]) > 0 && sum([
      for node_name, config in var.node_distribution : config.controlplane_count
    ]) % 2 == 1
    error_message = "Total control plane count must be a positive odd number for HA."
  }
}

# =============================================================================
# TAGGING CONFIGURATION
# =============================================================================

variable "tagging_config" {
  description = "Tagging configuration for resources"
  type = object({
    common = optional(list(string), ["talos", "terraform"])
    extra  = optional(list(string), [])
  })
  default = {
    common = ["talos", "terraform"]
    extra  = []
  }
}
