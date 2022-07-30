variable "vpc_cidr_block" {
  default = "10.0.0.0/16"
}

variable "pub_sub" {
  default = ["10.0.5.0/24", "10.0.6.0/24", "10.0.7.0/24"]
}
