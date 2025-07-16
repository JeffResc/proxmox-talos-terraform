# =============================================================================
# LOCAL VALUES FOR VARIABLE COMPATIBILITY
# =============================================================================

locals {
  # CCM configuration - use the passed in token values or empty strings
  ccm_token_id     = var.proxmox_config.ccm_config.enabled ? var.proxmox_config.ccm_config.token_id : ""
  ccm_token_secret = var.proxmox_config.ccm_config.enabled ? var.proxmox_config.ccm_config.token_secret : ""
}
