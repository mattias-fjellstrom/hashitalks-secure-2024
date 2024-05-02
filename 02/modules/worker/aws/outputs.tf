output "private_ip" {
  description = "Private IP of the worker EC2 instance"
  value       = aws_instance.this.private_ip
}

output "public_ip" {
  description = "Publi IP of the worker EC2 instance"
  value       = aws_instance.this.public_ip
}
