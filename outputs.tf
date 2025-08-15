output "instance_id" {
  description = "ID of the EC2 instance."
  value       = aws_instance.this.id
}

output "private_ip" {
  description = "Private IP address of the instance."
  value       = aws_instance.this.private_ip
}

output "public_ip" {
  description = "Public IP address of the instance (if associated)."
  value       = aws_instance.this.public_ip
}

output "security_group_id" {
  description = "ID of the managed security group (if created)."
  value       = try(aws_security_group.this[0].id, null)
}

output "iam_instance_profile" {
  description = "Name of the IAM instance profile (if created)."
  value       = try(aws_iam_instance_profile.this[0].name, null)
}
