data "terraform_remote_state" "level1" {
  backend = "s3"

  config = {
    bucket = "terraform-remote-state-mk-1508"
    key    = "remote/level1.tfstate"
    region = "ap-south-1"
  }
}
