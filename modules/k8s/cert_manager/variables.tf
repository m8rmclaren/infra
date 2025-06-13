variable "name" {
  type        = string
  description = "Release and namespace name"
  default     = "cert-manager"
}

variable "cert_manager_version" {
  type        = string
  description = "Version of cert-manager to install"
  default     = "v1.18.0"
}
