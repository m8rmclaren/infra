variable "domain" {
  description = "Your root domain name (e.g., example.com)"
  type        = string
}

variable "subdomain" {
  description = "The subdomain to create (e.g., 'api' for 'api.example.com')"
  type        = string
  default     = ""
}

variable "ip_address" {
  description = "The IP address the A record should point to"
  type        = string
}

variable "ttl" {
  description = "Time to live for the record (1 = auto)"
  type        = number
  default     = 1
}

variable "proxied" {
  description = "Whether Cloudflare proxy (orange cloud) is enabled"
  type        = bool
  default     = false
}
