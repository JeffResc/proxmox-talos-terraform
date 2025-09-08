terraform {
  required_version = ">= 1.0"

  required_providers {
    proxmox = {
      source  = "registry.opentofu.org/bpg/proxmox"
      version = "0.83.0"
    }
    talos = {
      source  = "registry.opentofu.org/siderolabs/talos"
      version = "0.9.0"
    }
    random = {
      source  = "registry.opentofu.org/hashicorp/random"
      version = "~> 3.1"
    }
  }
}
