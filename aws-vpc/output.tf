output "gk-aws-subnet-id" {
  description = "Id from the subnet"
  value       = aws_subnet.gk-aws-subnet.id
}

output "gk-aws-sg-id" {
  description = "Id from the security group"
  value       = aws_security_group.gk-aws-sg.id
}