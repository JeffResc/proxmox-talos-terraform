locals {
  # Construct the Proxmox endpoint URL from host and port
  proxmox_endpoint = "https://${var.proxmox_config.host}:${var.proxmox_config.port}/"
}
