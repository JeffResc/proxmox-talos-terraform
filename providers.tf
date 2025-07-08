provider "proxmox" {
  endpoint  = var.proxmox_endpoint
  insecure  = var.proxmox_insecure
  api_token = var.proxmox_api_token

  ssh {
    agent       = var.proxmox_ssh_agent
    username    = var.proxmox_ssh_username
    private_key = file(var.proxmox_ssh_private_key_path)
  }
}

provider "talos" {}
