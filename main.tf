resource "aws_vpc" "myvpc" {
  cidr_block       = var.vpc_cidr_block
  instance_tenancy = "default"

  tags = {
    Name       = "My Private VPC - ${var.env_code}"
    created_by = "Terraform"
  }
}

resource "aws_subnet" "pub-subnet" {
  count = length(var.pub_cidr)

  vpc_id            = aws_vpc.myvpc.id
  cidr_block        = var.pub_cidr[count.index]
  availability_zone = "ap-south-1a"

  tags = {
    Name       = "${var.env_code}-Pub-subnet-${count.index}"
    created_by = "Terraform"
  }
}

resource "aws_subnet" "pvt-sub" {
  count = length(var.pvt_cidr)

  vpc_id            = aws_vpc.myvpc.id
  cidr_block        = var.pvt_cidr[count.index] # private subnet ip range
  availability_zone = "ap-south-1b"

  tags = {
    Name       = "${var.env_code}-Pvt-subnet ${count.index}"
    created_by = "Terraform"
  }
}

resource "aws_internet_gateway" "myigw" {
  vpc_id = aws_vpc.myvpc.id

  tags = {
    Name = "My Internet Gateway - ${var.env_code}"
  }
}

resource "aws_eip" "nat_eip" {
  count = length(var.pub_cidr)

  vpc = true

  tags = {
    Name = "${var.env_code} My Elastic IP - ${count.index}"
  }
}

resource "aws_nat_gateway" "nat_gate" {
  count = length(var.pub_cidr)

  allocation_id = aws_eip.nat_eip[count.index].id
  subnet_id     = aws_subnet.pub-subnet[count.index].id

  tags = {
    Name = "${var.env_code} My NAT Gateway -${count.index} "
  }
}

resource "aws_route_table" "public" {
  count = length(var.pub_cidr)

  vpc_id = aws_vpc.myvpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.myigw.id
  }

  tags = {
    Name = " ${var.env_code} Public Route Table"
  }
}

resource "aws_route_table" "private" {
  count = length(var.pvt_cidr)

  vpc_id = aws_vpc.myvpc.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gate[count.index].id
  }

  tags = {
    Name = "${var.env_code} - Private Route Table ${count.index}"
  }
}

resource "aws_route_table_association" "public" {
  count = length(var.pub_cidr)

  subnet_id      = aws_subnet.pub-subnet[count.index].id
  route_table_id = aws_route_table.public[count.index].id
}

resource "aws_route_table_association" "private" {
  count = length(var.pvt_cidr)

  subnet_id      = aws_subnet.pvt-sub[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}
