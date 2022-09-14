locals {
  region = "ap-south-1"
  tags = {
    Owner = "Kishan"
    Environment = "dev"
    
  user_data = file("/userdata.sh")

  }
}



module "asg" {
  source  = "terraform-aws-modules/autoscaling/aws"
  version = "6.5.2"


}
