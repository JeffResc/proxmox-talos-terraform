output "ccm_user" {
  description = "Proxmox CCM user"
  value       = proxmox_virtual_environment_user.ccm
}

output "ccm_role" {
  description = "Proxmox CCM role"
  value       = proxmox_virtual_environment_role.ccm
}

output "ccm_token" {
  description = "Proxmox CCM token"
  value       = proxmox_virtual_environment_user_token.ccm
  sensitive   = true
}

output "ccm_token_id" {
  description = "Proxmox CCM token ID"
  value       = proxmox_virtual_environment_user_token.ccm.id
}

output "ccm_token_secret" {
  description = "Proxmox CCM token secret"
  value       = split("=", proxmox_virtual_environment_user_token.ccm.value)[1]
  sensitive   = true
}