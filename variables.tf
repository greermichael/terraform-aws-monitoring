variable "config_context" {
  description = "Kubernetes configuration context name to use for deployment"
}

variable "private_zone_name" {
  description = "Route 53 private hosted zone domain name (without ending period)"
}

variable "namespace" {
  description = "Namespace for deployments in Kubernetes"
  default     = "monitoring"
}

variable "grafana_password" {
  description = "Password to set for admin user account"
}
