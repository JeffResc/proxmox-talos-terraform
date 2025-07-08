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
          officialExtensions = data.talos_image_factory_extensions_versions.this.extensions_info[*].name
        }
      }
    }
  )
}

# Generate Talos configurations
resource "talos_machine_secrets" "this" {
  talos_version = var.talos_version
}

data "talos_machine_configuration" "controlplane" {
  cluster_name     = var.cluster_name
  machine_type     = "controlplane"
  cluster_endpoint = var.cluster_vip_enabled ? "https://${var.cluster_vip_ip}:6443" : var.cluster_endpoint_override
  machine_secrets  = talos_machine_secrets.this.machine_secrets

  config_patches = [
    yamlencode({
      machine = {
        network = {
          interfaces = [
            merge(
              {
                interface = var.network_interface
                dhcp      = var.enable_dhcp
              },
              var.cluster_vip_enabled ? {
                vip = {
                  ip = var.cluster_vip_ip
                }
              } : {}
            )
          ]
        }
      }
      cluster = {
        inlineManifests = [
          {
            name     = "proxmox-cloud-controller-manager-config"
            contents = <<-EOF
              apiVersion: v1
              kind: Secret
              metadata:
                name: proxmox-cloud-controller-manager
                namespace: kube-system
              stringData:
                config.yaml: |
                  clusters:
                    - url: "${trimsuffix(var.proxmox_endpoint, "/")}/api2/json"
                      insecure: ${var.proxmox_insecure}
                      token_id: "${var.ccm_token_id}"
                      token_secret: "${var.ccm_token_secret}"
                      region: "${var.cluster_name}"
            EOF
          }
        ]
        externalCloudProvider = {
          enabled = true
          manifests = [
            "https://raw.githubusercontent.com/sergelogvinov/proxmox-cloud-controller-manager/v0.9.0/docs/deploy/cloud-controller-manager.yml",
            "https://github.com/fluxcd/flux2/releases/download/v2.6.4/install.yaml",
            "https://raw.githubusercontent.com/siderolabs/talos-cloud-controller-manager/refs/tags/v1.10.1/docs/deploy/cloud-controller-manager.yml",
            "https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/refs/tags/v0.83.0/example/prometheus-operator-crd-full/monitoring.coreos.com_alertmanagers.yaml",
            "https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/refs/tags/v0.83.0/example/prometheus-operator-crd-full/monitoring.coreos.com_prometheuses.yaml",
            "https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/refs/tags/v0.83.0/example/prometheus-operator-crd-full/monitoring.coreos.com_prometheusrules.yaml",
            "https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/refs/tags/v0.83.0/example/prometheus-operator-crd-full/monitoring.coreos.com_servicemonitors.yaml"
          ]
        }
      }
    })
  ]
}

data "talos_machine_configuration" "worker" {
  cluster_name     = var.cluster_name
  machine_type     = "worker"
  cluster_endpoint = var.cluster_vip_enabled ? "https://${var.cluster_vip_ip}:6443" : var.cluster_endpoint_override
  machine_secrets  = talos_machine_secrets.this.machine_secrets

  config_patches = [
    yamlencode({
      machine = {
        network = {
          interfaces = [
            {
              interface = var.network_interface
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
    talos_machine_configuration_apply.controlplane
  ]

  client_configuration = talos_machine_secrets.this.client_configuration
  endpoint             = var.first_controlplane_endpoint
  node                 = var.first_controlplane_node
}

# Apply configuration to all controlplane nodes
resource "talos_machine_configuration_apply" "controlplane" {
  depends_on = [
    var.nodes_ready
  ]

  for_each = var.controlplane_nodes

  client_configuration        = talos_machine_secrets.this.client_configuration
  machine_configuration_input = data.talos_machine_configuration.controlplane.machine_configuration
  endpoint                    = each.value.endpoint
  node                        = each.value.node

  config_patches = [
    yamlencode({
      machine = {
        kubelet = {
          extraArgs = {
            provider-id = "proxmox://${var.cluster_name}/${each.value.vm_id}"
          }
        }
      }
    })
  ]
}

# Apply configuration to all worker nodes
resource "talos_machine_configuration_apply" "worker" {
  depends_on = [
    var.nodes_ready,
    talos_machine_bootstrap.this
  ]

  for_each = var.worker_nodes

  client_configuration        = talos_machine_secrets.this.client_configuration
  machine_configuration_input = data.talos_machine_configuration.worker.machine_configuration
  endpoint                    = each.value.endpoint
  node                        = each.value.node

  config_patches = [
    yamlencode({
      machine = {
        kubelet = {
          extraArgs = {
            provider-id = "proxmox://${var.cluster_name}/${each.value.vm_id}"
          }
        }
      }
    })
  ]
}

# Generate kubeconfig for the cluster
resource "talos_cluster_kubeconfig" "this" {
  depends_on = [
    talos_machine_bootstrap.this
  ]

  client_configuration = talos_machine_secrets.this.client_configuration
  endpoint             = var.first_controlplane_endpoint
  node                 = var.first_controlplane_node
}