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
  talos_version             = var.cluster_config.talos_version
  cluster_name              = var.cluster_config.name
  cluster_vip_enabled       = var.cluster_config.vip.enabled
  cluster_vip_ip            = var.cluster_config.vip.ip
  cluster_endpoint_override = var.cluster_config.endpoint_override
  proxmox_endpoint          = var.proxmox_config.endpoint
  proxmox_insecure          = var.proxmox_config.insecure

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
  talos_version   = var.cluster_config.talos_version
  cluster_name    = var.cluster_config.name
  network_cidr    = var.network_config.cidr
  network_gateway = var.network_config.gateway

  # Pass through infrastructure variables
  talos_disk_image_datastore_id = var.proxmox_config.talos_disk_image_datastore_id
  template_datastore_id         = var.proxmox_config.template_datastore_id
  vm_datastore_id               = var.proxmox_config.vm_datastore_id
  network_bridge                = var.network_config.bridge
  controlplane_ip_start         = var.node_config.controlplane_ip_start
  worker_ip_start               = var.node_config.worker_ip_start
  dns_servers                   = var.proxmox_config.dns_servers

  # Node distribution configuration
  # Since we're using simple counts, we need to create the node_distribution
  node_distribution = {
    (var.proxmox_config.node_name) = {
      controlplane_count = var.node_config.controlplane_count
      worker_count       = var.node_config.worker_count
    }
  }

  # Override defaults only if needed
  # enable_dhcp = true
  # controlplane_memory = 2048
  # worker_memory = 4096

  # Values from other modules
  schematic_id         = module.talos_bootstrap.image_factory_schematic_id
  talos_image_filename = module.talos_bootstrap.talos_image_filename
}
