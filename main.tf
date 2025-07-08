# Main configuration file
# This file demonstrates how to use the Talos Proxmox modules together
# Each module is standalone and can be used independently

# Proxmox Cloud Controller Manager
module "proxmox_ccm" {
  source = "./modules/proxmox-ccm"

  # Override defaults only if needed
  # proxmox_ccm_user = "custom-ccm-user@pve"
  # proxmox_ccm_role = "CustomCCMRole"
}

# Talos bootstrap and configuration
module "talos_bootstrap" {
  source = "./modules/talos-bootstrap"

  # Pass through shared variables
  talos_version             = var.talos_version
  cluster_name              = var.cluster_name
  cluster_vip_enabled       = var.cluster_vip_enabled
  cluster_vip_ip            = var.cluster_vip_ip
  cluster_endpoint_override = var.cluster_endpoint_override
  proxmox_endpoint          = var.proxmox_endpoint
  proxmox_insecure          = var.proxmox_insecure

  # Override defaults only if needed
  # network_interface = "ens18"
  # enable_dhcp = true

  # Values from other modules
  ccm_token_id                = module.proxmox_ccm.ccm_token_id
  ccm_token_secret            = module.proxmox_ccm.ccm_token_secret
  controlplane_nodes          = module.proxmox_infrastructure.controlplane_nodes
  worker_nodes                = module.proxmox_infrastructure.worker_nodes
  first_controlplane_endpoint = module.proxmox_infrastructure.first_controlplane_endpoint
  first_controlplane_node     = module.proxmox_infrastructure.first_controlplane_node
  nodes_ready                 = module.proxmox_infrastructure.nodes
}

# Proxmox infrastructure (VMs, templates, etc.)
module "proxmox_infrastructure" {
  source = "./modules/proxmox-infrastructure"

  # Pass through shared variables
  talos_version   = var.talos_version
  cluster_name    = var.cluster_name
  network_cidr    = var.network_cidr
  network_gateway = var.network_gateway

  # Override defaults only if needed
  # node_distribution = {
  #   "pve1" = {
  #     controlplane_count = 1
  #     worker_count = 2
  #   }
  #   "pve2" = {
  #     controlplane_count = 2
  #     worker_count = 1
  #   }
  # }
  # enable_dhcp = true
  # controlplane_memory = 2048
  # worker_memory = 4096

  # Values from other modules
  schematic_id         = module.talos_bootstrap.image_factory_schematic_id
  talos_image_filename = module.talos_bootstrap.talos_image_filename
}