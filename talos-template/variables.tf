variable "proxmox_endpoint" {
  type = string
  default = "https://your-proxmox:8006/"
}

variable "proxmox_insecure" {
  type = bool
  default = true
}

variable "talos_version" {
  type = string
  default = "v1.10.5"
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

variable "node_name" {
  type = string
  default = "pve"
}

variable "cluster_name" {
  description = "Name of the Talos cluster"
  type        = string
  default     = "talos-cluster"
}

variable "cluster_endpoint" {
  description = "Cluster endpoint URL"
  type        = string
  default     = "https://192.168.0.100:6443"
}

variable "controlplane_count" {
  description = "Number of control plane nodes"
  type        = number
  default     = 3
  validation {
    condition     = var.controlplane_count > 0 && var.controlplane_count % 2 == 1
    error_message = "Control plane count must be a positive odd number for HA."
  }
}

variable "worker_count" {
  description = "Number of worker nodes"
  type        = number
  default     = 3
  validation {
    condition     = var.worker_count >= 0
    error_message = "Worker count must be zero or positive."
  }
}

variable "network_cidr" {
  description = "Network CIDR for node IP addresses"
  type        = string
  default     = "192.168.0.0/24"
  validation {
    condition     = can(cidrhost(var.network_cidr, 0))
    error_message = "Network CIDR must be a valid CIDR notation."
  }
}

variable "network_gateway" {
  description = "Network gateway IP address"
  type        = string
  default     = "192.168.0.1"
}

variable "controlplane_ip_start" {
  description = "Starting IP address for control plane nodes (last octet)"
  type        = number
  default     = 50
  validation {
    condition     = var.controlplane_ip_start > 0 && var.controlplane_ip_start < 255
    error_message = "Control plane IP start must be between 1 and 254."
  }
}

variable "worker_ip_start" {
  description = "Starting IP address for worker nodes (last octet)"
  type        = number
  default     = 70
  validation {
    condition     = var.worker_ip_start > 0 && var.worker_ip_start < 255
    error_message = "Worker IP start must be between 1 and 254."
  }
}

variable "dns_servers" {
  description = "List of DNS servers for Talos nodes"
  type        = list(string)
  default     = ["192.168.0.1", "1.1.1.1", "1.0.0.1"]
}

variable "proxmox_ccm_user" {
  description = "Proxmox user for Cloud Controller Manager"
  type        = string
  default     = "talos-ccm@pve"
}

variable "proxmox_ccm_role" {
  description = "Proxmox role for Cloud Controller Manager"
  type        = string
  default     = "TalosCCM"
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
  default     = 2099
  validation {
    condition     = var.controlplane_vm_id_max > 0 && var.controlplane_vm_id_max < 10000
    error_message = "Control plane VM ID max must be between 1 and 9999."
  }
}

variable "worker_vm_id_min" {
  description = "Minimum VM ID for worker nodes"
  type        = number
  default     = 2100
  validation {
    condition     = var.worker_vm_id_min > 0 && var.worker_vm_id_min < 9999
    error_message = "Worker VM ID min must be between 1 and 9998."
  }
}

variable "worker_vm_id_max" {
  description = "Maximum VM ID for worker nodes"
  type        = number
  default     = 2199
  validation {
    condition     = var.worker_vm_id_max > 0 && var.worker_vm_id_max < 10000
    error_message = "Worker VM ID max must be between 1 and 9999."
  }
}

variable "enable_dhcp" {
  description = "Enable DHCP for node network interfaces"
  type        = bool
  default     = false
}

variable "enable_vip" {
  description = "Enable VIP (Virtual IP) for controlplane nodes"
  type        = bool
  default     = true
}
