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

resource "aws_launch_configuration" "main" {
  name_prefix          = "${var.env_code}-"
  image_id             = data.aws_ami.amazonlinux.id
  instance_type        = "t2.micro"
  security_groups      = [aws_security_group.private.id]
  user_data            = file("${path.module}/userdata.sh")
  key_name             = "dropmailtokishan"
  iam_instance_profile = aws_iam_instance_profile.main.name
}


resource "aws_autoscaling_group" "main" {
  name             = var.env_code
  min_size         = 2
  desired_capacity = 2
  max_size         = 4

  target_group_arns    = [var.target_group_arn]
  launch_configuration = aws_launch_configuration.main.name
  vpc_zone_identifier  = var.private_subnet_id

  tag {
    key                 = "Name"
    value               = "${var.env_code}-private"
    propagate_at_launch = true
  }
}
