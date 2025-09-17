# Outputs

# VPC ID
output "vpc_id" {
    description = "The ID of the VPC"
    value = aws_vpc.main.id
}

# Public Subnet IDs
output "public_subnet_ids" {
    description = "List of public subnet IDs"
    value = [
        aws_subnet.public_a.id,
        aws_subnet.public_b.id
    ]
}

# Private Subnet IDs
output "private_subnet_ids" {
    description = "List of private subnet IDs"
    value = [
        aws_subnet.private_a.id,
        aws_subnet.private_b.id
    ] 
}