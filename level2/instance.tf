data "aws_ami" "amazonlinux" {
  owners      = ["137112412989"]
  most_recent = true

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "name"
    values = ["amzn-ami-hvm-2018.03.0.20200904.0-x86*"]
  }
}

resource "aws_instance" "public" {
  ami                         = data.aws_ami.amazonlinux.id
  associate_public_ip_address = true
  instance_type               = "t2.micro"
  key_name                    = "main"
  vpc_security_group_ids      = [aws_security_group.public.id]
  subnet_id                   = data.terraform_remote_state.level1.outputs.public_subnet_id[1]
  user_data                   = file("userdata.sh")

  tags = {
    Name = "${var.env_code}-public"
  }
}

resource "aws_security_group" "public" {
  name        = "${var.env_code}-public"
  description = "Allow inbound traffic"
  vpc_id      = data.terraform_remote_state.level1.outputs.vpc_id

  ingress {
    description = "SSH from Public"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["223.182.193.64/32"]
  }

  ingress {
    description = "HTTP from Public"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["223.182.193.64/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.env_code}-public"
  }
}

resource "aws_instance" "private" {
  ami                    = "ami-0912f71e06545ad88"
  instance_type          = "t2.micro"
  key_name               = "main"
  vpc_security_group_ids = [aws_security_group.private.id]
  subnet_id              = data.terraform_remote_state.level1.outputs.private_subnet_id[1]
  user_data              = file("userdata.sh")

  tags = {
    Name = "${var.env_code}-private"
  }
}

resource "aws_security_group" "private" {
  name        = "${var.env_code}-private"
  description = "Allow inbound traffic"
  vpc_id      = data.terraform_remote_state.level1.outputs.vpc_id

  ingress {
    description = "SSH from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [data.terraform_remote_state.level1.outputs.vpc_cidr_block]
  }
  ingress {
    description     = "HTTP from load_balancer"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.load_balancer.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.env_code}-public"
  }
}
