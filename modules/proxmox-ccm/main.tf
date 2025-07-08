# Proxmox Cloud Controller Manager setup
resource "proxmox_virtual_environment_role" "ccm" {
  role_id = var.ccm_config.role

  privileges = var.ccm_config.privileges
}

resource "proxmox_virtual_environment_user" "ccm" {
  comment = "Talos Cloud Controller Manager service account"
  user_id = var.ccm_config.user
  enabled = true

  acl {
    path      = "/"
    propagate = true
    role_id   = proxmox_virtual_environment_role.ccm.role_id
  }
}

resource "proxmox_virtual_environment_user_token" "ccm" {
  comment               = "Talos CCM API token"
  token_name            = var.ccm_config.token_name
  user_id               = proxmox_virtual_environment_user.ccm.user_id
  privileges_separation = false
}
