variable "region" {
  type        = string
  default     = "sfo2"
  description = "DO region"
}

variable "droplet_size" {
  type    = string
  default = "s-1vcpu-1gb"
}

variable "ssh_key_id" {
  type        = string
  description = "DO SSH key ID that was already created in DO"
}

variable "ssh_key" {
  type        = string
  sensitive   = true
  description = "SSH private key associated with ssh_key_id"
}

variable "vpc_uuid" {
  type        = string
  description = "DO VPC UUID"
}

variable "public_ip" {
  type        = string
  description = "DO reserved IP address"
}
