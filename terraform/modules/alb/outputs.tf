# Output the DNS name of the Load Balancer
output "lb_dns_name" {
    description = "The DNS address of the Load Balancer"
    value = aws_lb.main.dns_name

}

# Output the name of the Load Balancer
output "load_balancer_name" {
    description = "The name of the Load Balancer"
    value = aws_lb.main.name
  
}