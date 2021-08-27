locals {
  subnets = cidrsubnets("10.0.0.0/16", 4, 4, 4, 4, 4, 4)

  public_subnets = slice(local.subnets, 0, length(local.subnets) / 2)

  private_subnets = slice(local.subnets, length(local.subnets) / 2, length(local.subnets))
}
