variable "cidr_block" {
  default = "10.0.0.0/16"
}

variable "enable_dns_support" {
  type = bool
  default = false
}

variable "enable_dns_hostnames" {
  default = false
}

variable "env" {
  default = "DEV"
}