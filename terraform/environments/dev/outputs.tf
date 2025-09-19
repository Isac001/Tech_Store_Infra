# This output displays the public IP address of the EC2 application instance.
# You can use this IP to access your web application in a browser (e.g., http://<IP>:5000).
output "app_public_ip" {
    description = "The public IP address of the EC2 application instance"
    value       = module.ec2_app.public_ip
}

# This output provides the connection endpoint (hostname) for the RDS database instance.
# The application uses this address to connect to the database.
output "database_endpoint" {
    description = "The endpoint of the RDS database instance"
    value       = module.rds_db.db_endpoint
}

# This output displays the randomly generated password for the database.
# It is marked as 'sensitive' so that Terraform will not show it in the console after `apply`.
# Use the command `terraform output -json database_generated_password` to view it when needed.
output "database_generated_password" {
  description = "Generated password for the database. Store it in a safe place."
  value       = random_password.db_password.result
  sensitive   = true
}

output "application_url" {
  description = "The URL to access the application via the Load Balancer"
  value       = "http://${module.alb.lb_dns_name}"
  
}