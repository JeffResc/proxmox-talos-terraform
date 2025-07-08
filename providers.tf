provider "proxmox" {
  endpoint  = var.proxmox_config.endpoint
  insecure  = var.proxmox_config.insecure
  api_token = var.proxmox_config.api_token
}
