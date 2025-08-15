provider "aws" {
  region = "us-east-1"
}

data "aws_ami" "al2023" {
  owners      = ["amazon"]
  most_recent = true
  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}

module "ec2" {
  source = "github.com/arkinfotech24/terraform-deployEC2"

  name                  = "my-ec2-demo"
  ami_id                = data.aws_ami.al2023.id
  instance_type         = "t3.micro"
  subnet_id             = "subnet-0ac19a8ca72369eef"
  create_security_group = true
  allowed_ssh_cidr      = ["0.0.0.0/0"]
  tags = {
    env = "dev"
    app = "artifact-store"
  }
}
