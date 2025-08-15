# terraform-deployEC2

Provision a **secure, minimal EC2 instance** with sane defaults:
- Optional IAM role + instance profile for **SSM Session Manager** access
- Optional managed **security group** with SSH ingress + all egress
- Encrypted **gp3** root volume (custom size/type)
- Plan-time tag check enforcing `env`

## Usage

```hcl
provider "aws" {
  region = "us-east-1"
}

# Get a recent Amazon Linux 2023 AMI (x86_64)
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

  name           = "demo-ec2"
  ami_id         = data.aws_ami.al2023.id
  instance_type  = "t3.micro"
  subnet_id      = "subnet-xxxxxxxx"
  key_name       = "your-keypair-name"     # optional
  associate_public_ip = true               # set false for private subnets

  # Provide your office/home IP in CIDR to restrict SSH, or leave empty
  allowed_ssh_cidr = ["0.0.0.0/0"]

  tags = {
    env = "dev"
    app = "demo"
  }
}
```

## Inputs
- `name` (string, required): base name for resources
- `ami_id` (string, required): AMI ID for instance
- `instance_type` (string, default `t3.micro`)
- `subnet_id` (string, required)
- `vpc_security_group_ids` (list(string), default `[]`)
- `create_security_group` (bool, default `true`)
- `allowed_ssh_cidr` (list(string), default `["0.0.0.0/0"]`)
- `associate_public_ip` (bool, default `true`)
- `key_name` (string, default `null`)
- `user_data` (string, default `null`)
- `root_volume_size` (number, default `20`)
- `root_volume_type` (string, default `gp3`)
- `kms_key_id` (string, default `null`)
- `enable_ssm` (bool, default `true`)
- `tags` (map(string), default `{}`)

## Outputs
- `instance_id`, `private_ip`, `public_ip`, `security_group_id`, `iam_instance_profile`

## Testing
Native `terraform test` example asserts EC2 is planned and outputs exist.

## Notes
- Module does **not** set backends; configure state in your root.
- Use Session Manager (enable_ssm=true) to avoid exposing SSH in production.
