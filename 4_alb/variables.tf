variable "vpc_id" {
  default = "vpc-07fa560fff8415af2"
}

variable "subnets" {
  type = list(string)
  default = ["subnet-058d4dbaf153c3906", "subnet-0151be7750e193890"]
}
