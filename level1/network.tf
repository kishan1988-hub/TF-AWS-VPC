module "vpc" {
  source = "../module/vpc"

  env_code       = var.env_code
  vpc_cidr_block = var.vpc_cidr_block
  private_cidr   = var.private_cidr
  public_cidr    = var.public_cidr
}
