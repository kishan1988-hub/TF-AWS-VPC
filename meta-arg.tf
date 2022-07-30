resource "aws_subnet" "pub_sub" {
  count = length(var.pub_sub)

  vpc_id     = aws_vpc.myvpc.id
  cidr_block = var.pub_sub[count.index]

  tags = {
    name = "Public Subnet - ${count.index}"
  }
}
