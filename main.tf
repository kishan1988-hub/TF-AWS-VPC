resource "aws_vpc" "main" {
  cidr_block       = var.vpc_cidr_block
  instance_tenancy = "default"

  tags = {
    Name       = "my-private-vpc-${var.env_code}"
  }
}

resource "aws_subnet" "public" {
  count = length(var.pub_cidr)

  vpc_id            = aws_vpc.main.id
  cidr_block        = var.pub_cidr[count.index]
  availability_zone = "ap-south-1a"

  tags = {
    Name       = "${var.env_code}-public-subnet-${count.index}"
  }
}

resource "aws_subnet" "private" {
  count = length(var.pvt_cidr)

  vpc_id            = aws_vpc.main.id
  cidr_block        = var.pvt_cidr[count.index] # private subnet ip range
  availability_zone = "ap-south-1b"

  tags = {
    Name       = "${var.env_code}-private-subnet-${count.index}"
  }
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "my-internet-gateway-${var.env_code}"
  }
}

resource "aws_eip" "main" {
  count = length(var.pub_cidr)

  vpc = true

  tags = {
    Name = "${var.env_code}-my-elastic-ip-${count.index}"
  }
}

resource "aws_nat_gateway" "this" {
  count = length(var.pub_cidr)

  allocation_id = aws_eip.main[count.index].id
  subnet_id     = aws_subnet.public[count.index].id

  tags = {
    Name = "${var.env_code}-my-nat-gateway-${count.index} "
  }
}

resource "aws_route_table" "public" {
  count = length(var.pub_cidr)

  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }

  tags = {
    Name = " ${var.env_code}-public-route-table"
  }
}

resource "aws_route_table" "private" {
  count = length(var.pvt_cidr)

  vpc_id = aws_vpc.main.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.this[count.index].id
  }

  tags = {
    Name = "${var.env_code}-private-route-table-${count.index}"
  }
}

resource "aws_route_table_association" "public" {
  count = length(var.pub_cidr)

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public[count.index].id
}

resource "aws_route_table_association" "private" {
  count = length(var.pvt_cidr)

  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}
