resource "aws_vpc" "myvpc" {
  cidr_block       = var.vpc_cidr_block
  instance_tenancy = "default"
}

locals {
  pub_cidr = ["10.0.1.0/24", "10.0.2.0/24"]
  pvt_cidr = ["10.0.3.0/24", "10.0.4.0/24"]
}

resource "aws_subnet" "pub-subnet" {
  count             = 2
  vpc_id            = aws_vpc.myvpc.id
  cidr_block        = local.pub_cidr[count.index]
  availability_zone = "ap-south-1a"
}

resource "aws_subnet" "pvt-sub" {
  count             = 2
  vpc_id            = aws_vpc.myvpc.id
  cidr_block        = local.pvt_cidr[count.index] # private subnet ip range
  availability_zone = "ap-south-1b"
}

resource "aws_internet_gateway" "myigw" {
  vpc_id = aws_vpc.myvpc.id
}

resource "aws_eip" "nat_eip" {
  vpc   = true
  count = 2
}

resource "aws_nat_gateway" "nat_gate" {
  count         = 2
  allocation_id = aws_eip.nat_eip[count.index].id
  subnet_id     = aws_subnet.pub-subnet[count.index].id
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.myvpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.myigw.id
  }
}

resource "aws_route_table" "private" {
  count  = 2
  vpc_id = aws_vpc.myvpc.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gate[count.index].id
  }
}

resource "aws_route_table_association" "public" {
  count          = 2
  subnet_id      = aws_subnet.pub-subnet[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  count          = 2
  subnet_id      = aws_subnet.pvt-sub[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}
