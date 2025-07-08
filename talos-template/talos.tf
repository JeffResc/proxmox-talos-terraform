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
  content_type = "import"
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
            merge(
              {
                interface = "eth0"
                dhcp      = var.enable_dhcp
              },
              var.enable_vip ? {
                vip = {
                  ip = regex("https?://([^:]+)", var.cluster_endpoint)[0]
                }
              } : {}
            )
          ]
        }
      }
      cluster = {
        inlineManifests = [
          {
            name = "proxmox-cloud-controller-manager-config"
            contents = <<-EOF
              apiVersion: v1
              kind: Secret
              metadata:
                name: proxmox-cloud-controller-manager
                namespace: kube-system
              stringData:
                config.yaml: |
                  clusters:
                    - url: "${var.proxmox_endpoint}"
                      insecure: ${var.proxmox_insecure}
                      token_id: "${proxmox_virtual_environment_user_token.ccm.id}"
                      token_secret: "${proxmox_virtual_environment_user_token.ccm.value}"
                      region: "${var.node_name}"
            EOF
          }
        ]
        externalCloudProvider = {
          enabled = true
          manifests = [
            "https://raw.githubusercontent.com/sergelogvinov/proxmox-cloud-controller-manager/v0.9.0/docs/deploy/cloud-controller-manager-talos.yml"
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
              dhcp      = var.enable_dhcp
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
  endpoint             = proxmox_virtual_environment_vm.controlplane_nodes[0].ipv4_addresses[index(proxmox_virtual_environment_vm.controlplane_nodes[0].network_interface_names, "eth0")][0]
  node                 = proxmox_virtual_environment_vm.controlplane_nodes[0].ipv4_addresses[index(proxmox_virtual_environment_vm.controlplane_nodes[0].network_interface_names, "eth0")][0]
}

# Apply configuration to all controlplane nodes
resource "talos_machine_configuration_apply" "controlplane" {
  depends_on = [
    proxmox_virtual_environment_vm.controlplane_nodes
  ]
  
  count                       = var.controlplane_count
  client_configuration        = talos_machine_secrets.this.client_configuration
  machine_configuration_input = data.talos_machine_configuration.controlplane.machine_configuration
  endpoint                    = proxmox_virtual_environment_vm.controlplane_nodes[count.index].ipv4_addresses[index(proxmox_virtual_environment_vm.controlplane_nodes[count.index].network_interface_names, "eth0")][0]
  node                        = proxmox_virtual_environment_vm.controlplane_nodes[count.index].ipv4_addresses[index(proxmox_virtual_environment_vm.controlplane_nodes[count.index].network_interface_names, "eth0")][0]
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
  endpoint                    = proxmox_virtual_environment_vm.worker_nodes[count.index].ipv4_addresses[index(proxmox_virtual_environment_vm.worker_nodes[count.index].network_interface_names, "eth0")][0]
  node                        = proxmox_virtual_environment_vm.worker_nodes[count.index].ipv4_addresses[index(proxmox_virtual_environment_vm.worker_nodes[count.index].network_interface_names, "eth0")][0]
}