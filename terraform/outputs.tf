output "instance_ip" {
  description = "Endereço IP público da instância WordPress"
  value       = aws_instance.wordpress_vm.public_ip
}

output "aws_access_key_id" {
  value = aws_iam_access_key.ec2_user_key.id
}

output "aws_secret_access_key" {
  value = aws_iam_access_key.ec2_user_key.secret
  sensitive = true
}