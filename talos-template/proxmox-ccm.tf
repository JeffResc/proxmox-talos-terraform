# Proxmox Cloud Controller Manager setup
resource "proxmox_virtual_environment_role" "ccm" {
  role_id = var.proxmox_ccm_role
  
  privileges = [
    "VM.Audit"
  ]
}

resource "proxmox_virtual_environment_user" "ccm" {
  comment  = "Talos Cloud Controller Manager service account"
  user_id  = var.proxmox_ccm_user
  enabled  = true
  
  acl {
    path      = "/"
    propagate = true
    role_id   = proxmox_virtual_environment_role.ccm.role_id
  }
}

resource "proxmox_virtual_environment_user_token" "ccm" {
  comment               = "Talos CCM API token"
  token_name            = "ccm-token"
  user_id               = proxmox_virtual_environment_user.ccm.user_id
  privileges_separation = false
}