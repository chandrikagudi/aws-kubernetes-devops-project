output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.main.id
}

output "public_subnet_az1_id" {
  description = "Public subnet AZ1"
  value       = aws_subnet.public_az1.id
}

output "public_subnet_az2_id" {
  description = "Public subnet AZ2"
  value       = aws_subnet.public_az2.id
}

output "private_subnet_az1_id" {
  description = "Private subnet AZ1"
  value       = aws_subnet.private_az1.id
}

output "private_subnet_az2_id" {
  description = "Private subnet AZ2"
  value       = aws_subnet.private_az2.id
}

output "internet_gateway_id" {
  description = "Internet Gateway ID"
  value       = aws_internet_gateway.main.id
}
output "ec2_instance_1_id" {
  description = "EC2 instance 1 ID"
  value       = aws_instance.app_server_1.id
}

output "ec2_instance_1_public_ip" {
  description = "EC2 instance 1 public IP"
  value       = aws_instance.app_server_1.public_ip
}

output "ec2_instance_2_id" {
  description = "EC2 instance 2 ID"
  value       = aws_instance.app_server_2.id
}

output "ec2_instance_2_public_ip" {
  description = "EC2 instance 2 public IP"
  value       = aws_instance.app_server_2.public_ip
}