
data "aws_route53_zone" "this" {
  name = "kishanmukundu.co.in"
}

module "acm" {
  source  = "terraform-aws-modules/acm/aws"
  version = "~> 3.0"

  domain_name = "www.kishanmukundu.co.in" # trimsuffix(data.aws_route53_zone.this.name, ".")
  zone_id     = data.aws_route53_zone.this.id
}

module "security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4.0"

  name        = "${var.env_code}-load-balancer"
  description = "Allow Port 80 TCP inbound traffic to ELB"
  vpc_id      = data.terraform_remote_state.level1.outputs.vpc_id

  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules       = ["http-80-tcp", "all-icmp"]
  egress_rules        = ["all-all"]
}


module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 6.0"

  name = "my-alb"

  load_balancer_type = "application"

  vpc_id          = data.terraform_remote_state.level1.outputs.vpc_id
  subnets         = data.terraform_remote_state.level1.outputs.public_subnet_id
  security_groups = [module.security_group.security_group_id]

  access_logs = {
    bucket = "my-alb-logs"
  }

  target_groups = [
    {
      name_prefix      = "pref-"
      backend_protocol = "HTTP"
      backend_port     = 80
      health_check = [
        {
          enabled             = true
          path                = "/"
          port                = "traffic-port"
          matcher             = 200
          healthy_threshold   = 5
          unhealthy_threshold = 2
          timeout             = 5
          interval            = 30
        }
      ]
    }
  ]

  https_listeners = [
    {
      port               = 443
      protocol           = "HTTPS"
      certificate_arn    = module.acm.acm_certificate_arn
      target_group_index = 0
    }
  ]

  http_tcp_listeners = [
    {
      port               = 80
      protocol           = "HTTP"
      target_group_index = 0
    }
  ]

  tags = {
    Environment = "Dev"
  }
}
