variable "vpc_cidr_block" {
  default = "10.0.0.0/16"
}

variable "env_code" {
  type = string
}

variable "public_cidr" {}

variable "private_cidr" {}

variable "az_name" {

}
