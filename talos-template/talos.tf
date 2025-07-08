# Talos configuration resources
data "talos_image_factory_extensions_versions" "this" {
  talos_version = var.talos_version
  filters = {
    names = [
      "qemu-guest-agent",
    ]
  }
}

resource "talos_image_factory_schematic" "this" {
  schematic = yamlencode(
    {
      customization = {
        systemExtensions = {
          officialExtensions = data.talos_image_factory_extensions_versions.this.extensions_info.*.name
        }
      }
    }
  )
}

resource "proxmox_virtual_environment_download_file" "talos_image" {
  content_type = "iso"
  datastore_id = var.talos_disk_image_datastore_id
  node_name    = var.node_name
  file_name    = local.talos_image_filename
  url          = "https://factory.talos.dev/image/${talos_image_factory_schematic.this.id}/${var.talos_version}/nocloud-amd64.qcow2"
  overwrite    = true
}

# Generate Talos configurations
resource "talos_machine_secrets" "this" {
  talos_version = var.talos_version
}

data "talos_machine_configuration" "controlplane" {
  cluster_name     = var.cluster_name
  machine_type     = "controlplane"
  cluster_endpoint = var.cluster_endpoint
  machine_secrets  = talos_machine_secrets.this.machine_secrets

  config_patches = [
    yamlencode({
      machine = {
        network = {
          interfaces = [
            {
              interface = "eth0"
              dhcp      = false
              vip = {
                ip = regex("https?://([^:]+)", var.cluster_endpoint)[0]
              }
            }
          ]
        }
      }
    })
  ]
}

data "talos_machine_configuration" "worker" {
  cluster_name     = var.cluster_name
  machine_type     = "worker"
  cluster_endpoint = var.cluster_endpoint
  machine_secrets  = talos_machine_secrets.this.machine_secrets

  config_patches = [
    yamlencode({
      machine = {
        network = {
          interfaces = [
            {
              interface = "eth0"
              dhcp      = false
            }
          ]
        }
      }
    })
  ]
}

# Bootstrap the cluster on the first controlplane node
resource "talos_machine_bootstrap" "this" {
  depends_on = [
    proxmox_virtual_environment_vm.controlplane_nodes
  ]

  client_configuration = talos_machine_secrets.this.client_configuration
  endpoint             = cidrhost(var.network_cidr, var.controlplane_ip_start)
  node                 = cidrhost(var.network_cidr, var.controlplane_ip_start)
}

# Apply configuration to all controlplane nodes
resource "talos_machine_configuration_apply" "controlplane" {
  depends_on = [
    proxmox_virtual_environment_vm.controlplane_nodes
  ]

  count                       = var.controlplane_count
  client_configuration        = talos_machine_secrets.this.client_configuration
  machine_configuration_input = data.talos_machine_configuration.controlplane.machine_configuration
  endpoint                    = cidrhost(var.network_cidr, var.controlplane_ip_start + count.index)
  node                        = cidrhost(var.network_cidr, var.controlplane_ip_start + count.index)
}

# Apply configuration to all worker nodes
resource "talos_machine_configuration_apply" "worker" {
  depends_on = [
    proxmox_virtual_environment_vm.worker_nodes,
    talos_machine_bootstrap.this
  ]

  count                       = var.worker_count
  client_configuration        = talos_machine_secrets.this.client_configuration
  machine_configuration_input = data.talos_machine_configuration.worker.machine_configuration
  endpoint                    = cidrhost(var.network_cidr, var.worker_ip_start + count.index)
  node                        = cidrhost(var.network_cidr, var.worker_ip_start + count.index)
}