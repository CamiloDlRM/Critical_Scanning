output "private_subnet_id" {
  description = "The ID of the private subnet"
  value       = aws_subnet.dev_private_subnet.id
}