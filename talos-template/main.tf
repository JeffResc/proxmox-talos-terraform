# Main configuration file
# This file serves as the entry point for the Talos Proxmox module
# All resources are now organized in separate files:
# - talos.tf: Talos-specific resources and configurations
# - templates.tf: VM templates for control plane and worker nodes
# - cloud-init.tf: Cloud-init configuration files
# - nodes.tf: VM instances for control plane and worker nodes
# - variables.tf: Input variables
# - outputs.tf: Output values
# - locals.tf: Local values and computed expressions
# - providers.tf: Provider configurations
# - versions.tf: Terraform and provider version constraints