variable "ccm_config" {
  description = "Configuration for Proxmox Cloud Controller Manager"
  type = object({
    enabled    = bool
    user       = optional(string, "talos-ccm@pve")
    role       = optional(string, "TalosCCM")
    token_name = optional(string, "ccm-token")
    privileges = optional(list(string), ["VM.Audit"])
  })
  default = {
    enabled    = true
    user       = "talos-ccm@pve"
    role       = "TalosCCM"
    token_name = "ccm-token"
    privileges = ["VM.Audit"]
  }
}
