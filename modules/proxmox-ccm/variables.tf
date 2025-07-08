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