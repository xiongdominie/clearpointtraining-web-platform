output "instance_id" {
  description = "The EC2 instance ID."
  value       = aws_instance.web.id
}

output "public_ip" {
  description = "The public IP address."
  value       = aws_instance.web.public_ip
}

output "public_dns" {
  description = "The public DNS name."
  value       = aws_instance.web.public_dns
}