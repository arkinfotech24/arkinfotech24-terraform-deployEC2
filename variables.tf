variable "name" {
  description = "Base name for resources (used in tags and resource names)."
  type        = string
  validation {
    condition     = length(var.name) >= 3 && length(var.name) <= 64
    error_message = "name must be 3..64 characters."
  }
}

variable "ami_id" {
  description = "AMI ID for the instance (e.g., AL2023)."
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type."
  type        = string
  default     = "t3.micro"
}

variable "subnet_id" {
  description = "Subnet ID to launch the instance in."
  type        = string
}

variable "vpc_security_group_ids" {
  description = "Additional security groups to associate with the instance."
  type        = list(string)
  default     = []
}

variable "create_security_group" {
  description = "If true, create and attach a managed security group."
  type        = bool
  default     = true
}

variable "allowed_ssh_cidr" {
  description = "CIDR blocks allowed to SSH to the instance (used when create_security_group=true)."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "associate_public_ip" {
  description = "Associate a public IP with the instance (usually true for public subnets)."
  type        = bool
  default     = true
}

variable "key_name" {
  description = "Name of an existing EC2 Key Pair to allow SSH access (optional)."
  type        = string
  default     = null
}

variable "user_data" {
  description = "User data script to run at boot."
  type        = string
  default     = null
}

variable "root_volume_size" {
  description = "Size of the root EBS volume in GiB."
  type        = number
  default     = 20
}

variable "root_volume_type" {
  description = "Type of the root EBS volume."
  type        = string
  default     = "gp3"
}

variable "kms_key_id" {
  description = "KMS Key ID for EBS encryption (if null, default EBS encryption is used)."
  type        = string
  default     = null
}

variable "enable_ssm" {
  description = "Create an IAM role/profile with SSM core policy for Session Manager access."
  type        = bool
  default     = true
}

variable "tags" {
  description = "Common tags to apply to all resources."
  type        = map(string)
  default     = {}
}
