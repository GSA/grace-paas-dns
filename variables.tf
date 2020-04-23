
variable "appenv" {
  type        = string
  description = "(optional) The application environment"
  default     = "development"
}

variable "is_hub" {
  type        = bool
  description = "(optional) Indicates whether this account is the DNS Hub (default: false)"
  value       = false
}

variable "internal_domain" {
  type        = string
  description = "(required) The domain name used internally for AWS name resolution"
}

variable "external_domain" {
  type        = string
  description = "(required) The domain name used externally for name resolution"
}

variable "external_dns_server" {
  type        = string
  description = "(required) The IP Address of the external DNS server"
}
