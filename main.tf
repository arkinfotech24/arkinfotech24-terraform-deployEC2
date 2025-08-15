locals {
  module_name = "deploy-ec2"
  common_tags = merge(
    {
      "terraform_module" = local.module_name
      "managed_by"       = "terraform"
      "Name"             = var.name
    },
    var.tags
  )
}

# Optional IAM role + instance profile for SSM
resource "aws_iam_role" "this" {
  count = var.enable_ssm ? 1 : 0
  name  = "${var.name}-ssm-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = { Service = "ec2.amazonaws.com" },
      Action = "sts:AssumeRole"
    }]
  })
  tags = local.common_tags
}

resource "aws_iam_role_policy_attachment" "ssm" {
  count      = var.enable_ssm ? 1 : 0
  role       = aws_iam_role.this[0].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "this" {
  count = var.enable_ssm ? 1 : 0
  name  = "${var.name}-instance-profile"
  role  = aws_iam_role.this[0].name
  tags  = local.common_tags
}

# Optional managed security group
resource "aws_security_group" "this" {
  count       = var.create_security_group ? 1 : 0
  name        = "${var.name}-sg"
  description = "Managed SG for ${var.name}"
  vpc_id      = data.aws_subnet.selected.vpc_id
  tags        = local.common_tags
}

resource "aws_vpc_security_group_egress_rule" "all_egress" {
  count             = var.create_security_group ? 1 : 0
  security_group_id = aws_security_group.this[0].id
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
  description       = "Allow all egress"
}

resource "aws_vpc_security_group_ingress_rule" "ssh" {
  count             = var.create_security_group ? 1 : 0
  security_group_id = aws_security_group.this[0].id
  ip_protocol       = "tcp"
  from_port         = 22
  to_port           = 22
  cidr_ipv4         = length(var.allowed_ssh_cidr) > 0 ? null : "0.0.0.0/0"
  cidr_blocks       = length(var.allowed_ssh_cidr) > 0 ? var.allowed_ssh_cidr : null
  description       = "Allow SSH"
}

# Helper to fetch VPC from the subnet
data "aws_subnet" "selected" {
  id = var.subnet_id
}

# Compute final SG set
locals {
  managed_sg_ids = var.create_security_group ? [aws_security_group.this[0].id] : []
  final_sg_ids   = concat(local.managed_sg_ids, var.vpc_security_group_ids)
}

resource "aws_instance" "this" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  key_name                    = var.key_name
  vpc_security_group_ids      = local.final_sg_ids
  associate_public_ip_address = var.associate_public_ip
  user_data                   = var.user_data
  iam_instance_profile        = var.enable_ssm ? aws_iam_instance_profile.this[0].name : null

  root_block_device {
    volume_type = var.root_volume_type
    volume_size = var.root_volume_size
    encrypted   = true
    kms_key_id  = var.kms_key_id
  }

  tags = local.common_tags
}

check "required_tags" {
  assert {
    condition     = contains(keys(local.common_tags), "env")
    error_message = "Tag 'env' is required; pass via var.tags."
  }
}
