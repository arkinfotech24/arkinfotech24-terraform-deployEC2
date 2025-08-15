provider "aws" {
  region = "us-east-1"
}

# Keep fixture deterministic by using a placeholder AMI (replace in CI via env if desired).
# For local testing, override ami_id with a -var flag or TF_VAR_ami_id.
module "under_test" {
  source = "../../.."

  name                  = "tf-test-ec2-123456"
  ami_id                = "ami-0a7d80731ae1b2435" # replace when running real tests
  instance_type         = "t3.micro"
  subnet_id             = "subnet-0ac19a8ca72369eef"
  create_security_group = false
  vpc_security_group_ids = []
  tags                  = { env = "test" }
}
