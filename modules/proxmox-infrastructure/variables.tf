variable "cluster_name" {
  description = "Name of the Talos cluster"
  type        = string
  default     = "talos"
}

variable "talos_version" {
  description = "Version of Talos Linux to use"
  type        = string
  default     = "v1.10.5" # renovate: datasource=github-releases depName=siderolabs/talos
}

variable "schematic_id" {
  description = "Talos image factory schematic ID"
  type        = string
}

variable "talos_image_filename" {
  description = "Talos image filename"
  type        = string
}

variable "talos_disk_image_datastore_id" {
  description = "Datastore for downloading Talos disk images"
  type        = string
  default     = "local"
}

variable "template_datastore_id" {
  description = "Datastore for VM template disks"
  type        = string
  default     = "local-lvm"
}

variable "vm_datastore_id" {
  description = "Datastore for VM initialization"
  type        = string
  default     = "local-lvm"
}

variable "image_download_node" {
  description = "Proxmox node where Talos disk images are downloaded"
  type        = string
  default     = "pve"
}

variable "template_node" {
  description = "Proxmox node where VM templates are created"
  type        = string
  default     = "pve"
}

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

variable "controlplane_template_id" {
  description = "VM ID for the control plane template"
  type        = number
  default     = 998
  validation {
    condition     = var.controlplane_template_id > 0 && var.controlplane_template_id < 10000
    error_message = "Control plane template ID must be between 1 and 9999."
  }
}

variable "worker_template_id" {
  description = "VM ID for the worker template"
  type        = number
  default     = 999
  validation {
    condition     = var.worker_template_id > 0 && var.worker_template_id < 10000
    error_message = "Worker template ID must be between 1 and 9999."
  }
}

variable "controlplane_memory" {
  description = "Memory for control plane nodes in MB"
  type        = number
  default     = 4096
  validation {
    condition     = var.controlplane_memory >= 2048
    error_message = "Control plane memory must be at least 2048 MB."
  }
}

variable "worker_memory" {
  description = "Memory for worker nodes in MB"
  type        = number
  default     = 8192
  validation {
    condition     = var.worker_memory >= 2048
    error_message = "Worker memory must be at least 2048 MB."
  }
}

variable "controlplane_cpu_cores" {
  description = "Number of CPU cores for control plane nodes"
  type        = number
  default     = 4
  validation {
    condition     = var.controlplane_cpu_cores >= 2
    error_message = "Control plane CPU cores must be at least 2."
  }
}

variable "worker_cpu_cores" {
  description = "Number of CPU cores for worker nodes"
  type        = number
  default     = 8
  validation {
    condition     = var.worker_cpu_cores >= 2
    error_message = "Worker CPU cores must be at least 2."
  }
}

variable "controlplane_disk_size" {
  description = "Disk size for control plane nodes in GB"
  type        = number
  default     = 20
  validation {
    condition     = var.controlplane_disk_size >= 10
    error_message = "Control plane disk size must be at least 10 GB."
  }
}

variable "worker_disk_size" {
  description = "Disk size for worker nodes in GB"
  type        = number
  default     = 50
  validation {
    condition     = var.worker_disk_size >= 20
    error_message = "Worker disk size must be at least 20 GB."
  }
}

variable "cpu_type" {
  description = "CPU type for VMs"
  type        = string
  default     = "x86-64-v2-AES"
}

variable "network_bridge" {
  description = "Network bridge for VM network interfaces"
  type        = string
  default     = "vmbr0"
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = list(string)
  default     = ["talos", "terraform"]
}

variable "extra_tags" {
  type        = list(string)
  description = "Extra tags to add to resources"
  default     = []
}

variable "controlplane_vm_id_min" {
  description = "Minimum VM ID for control plane nodes"
  type        = number
  default     = 2000
  validation {
    condition     = var.controlplane_vm_id_min > 0 && var.controlplane_vm_id_min < 9999
    error_message = "Control plane VM ID min must be between 1 and 9998."
  }
}

variable "controlplane_vm_id_max" {
  description = "Maximum VM ID for control plane nodes"
  type        = number
  default     = 2999
  validation {
    condition     = var.controlplane_vm_id_max > 0 && var.controlplane_vm_id_max < 10000
    error_message = "Control plane VM ID max must be between 1 and 9999."
  }
}

variable "worker_vm_id_min" {
  description = "Minimum VM ID for worker nodes"
  type        = number
  default     = 3000
  validation {
    condition     = var.worker_vm_id_min > 0 && var.worker_vm_id_min < 9999
    error_message = "Worker VM ID min must be between 1 and 9998."
  }
}

variable "worker_vm_id_max" {
  description = "Maximum VM ID for worker nodes"
  type        = number
  default     = 3999
  validation {
    condition     = var.worker_vm_id_max > 0 && var.worker_vm_id_max < 10000
    error_message = "Worker VM ID max must be between 1 and 9999."
  }
}

variable "controlplane_ip_start" {
  description = "Starting IP address for control plane nodes (last octet) (ignored when enable_dhcp is true)"
  type        = number
  default     = 50
  validation {
    condition     = var.controlplane_ip_start > 0 && var.controlplane_ip_start < 255
    error_message = "Control plane IP start must be between 1 and 254."
  }
}

variable "worker_ip_start" {
  description = "Starting IP address for worker nodes (last octet) (ignored when enable_dhcp is true)"
  type        = number
  default     = 70
  validation {
    condition     = var.worker_ip_start > 0 && var.worker_ip_start < 255
    error_message = "Worker IP start must be between 1 and 254."
  }
}

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

variable "enable_dhcp" {
  description = "Enable DHCP for node network interfaces. When true, static IP variables (network_cidr, network_gateway, controlplane_ip_start, worker_ip_start) are ignored"
  type        = bool
  default     = false
}

variable "dns_servers" {
  description = "List of DNS servers for Talos nodes (applied regardless of enable_dhcp setting)"
  type        = list(string)
  default     = ["1.1.1.1", "1.0.0.1"]
}

variable "network_interface" {
  description = "Network interface name for node network configuration"
  type        = string
  default     = "eth0"
}