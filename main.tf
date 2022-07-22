# Creating my vpc with CIDR Block provided
resource "aws_vpc" "myvpc" {
    cidr_block = var.vpc_cidr_block  # ip range for the VPC
    instance_tenancy = "default"
    tags = {
      Name = "myvpc"
    }
}

# declaring local var to be consumed during creation of public subnet

locals {
  pub_cidr = ["10.0.1.0/24","10.0.2.0/24"]
  pvt_cidr = ["10.0.3.0/24","10.0.4.0/24"]
}
# Subnets creation both public
resource "aws_subnet" "pub-subnet" {
  count = 2
  vpc_id = aws_vpc.myvpc.id
  cidr_block = local.pub_cidr[count.index]  # Public subnet ip range from local var
  availability_zone = "ap-south-1a"
  tags = {
    Name = "Public Subnet ${count.index}"
  }
}



# Subnets creation both public & private
resource "aws_subnet" "pvt-sub" {
  count = 2
  vpc_id = aws_vpc.myvpc.id
  cidr_block = local.pvt_cidr[count.index]  # private subnet ip range
  availability_zone = "ap-south-1b"
  tags = {
    Name = "Private Subnet ${count.index}"
  }
}


# internet gateway creation and attaching to VPC
resource "aws_internet_gateway" "myigw" {
    vpc_id = aws_vpc.myvpc.id
    tags = {
      Name = "myigw"
    }
}


resource "aws_eip" "nat_eip" {
    vpc = true
    count = 2
}


resource "aws_nat_gateway" "nat_gate" {
    count = 2
    allocation_id = aws_eip.nat_eip[count.index].id
    subnet_id = aws_subnet.pub-subnet[count.index].id
    tags = {
      name = "Nat Gateway "
    }
}


# creation of route tables

resource "aws_route_table" "public" {
    vpc_id = aws_vpc.myvpc.id
    route {
      cidr_block = "0.0.0.0/0"
      gateway_id = aws_internet_gateway.myigw.id
    }
    tags = {
      name = "Public RT"
    }
}

resource "aws_route_table" "private" {
  count = 2
    vpc_id = aws_vpc.myvpc.id
    route {
      cidr_block = "0.0.0.0/0"
      nat_gateway_id = aws_nat_gateway.nat_gate[count.index].id
    }
    tags = {
      name = "Private RT"
    }
}

#route table association
resource "aws_route_table_association" "public" {
    count = 2
    subnet_id = aws_subnet.pub-subnet[count.index].id
    route_table_id = aws_route_table.public.id
}


resource "aws_route_table_association" "private" {
    count = 2
    subnet_id = aws_subnet.pvt-sub[count.index].id
    route_table_id = aws_route_table.private[count.index].id
}
