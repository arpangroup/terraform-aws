variable "instance_ami_t2_micro" {
  type    = string
  default = "ami-0453ec754f44f9a4a"
}

variable "instance_type" {
  type    = string
  default = "t2.micro"
}

variable "vpc_id" {
  type    = string
  default = "vpc-07fa560fff8415af2" # default VPC ID from AWS console
}


variable "enable_public_ip" {
  type    = bool
  default = true
}

variable "tags" {
  type    = list(string)
  default = ["terraform", "example"]
}