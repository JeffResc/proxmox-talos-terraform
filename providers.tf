provider "proxmox" {
  endpoint  = local.proxmox_endpoint
  insecure  = var.proxmox_config.insecure
  api_token = var.proxmox_config.api_token
}
