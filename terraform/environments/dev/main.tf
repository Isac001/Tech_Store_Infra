# Configures the AWS provider, setting the default region for all resources created in this configuration.
provider "aws" {
  region = var.aws_region
}

# Data source to fetch your current public IP address from an external service.
# This is used to dynamically create a secure SSH rule in the EC2 security group.
data "http" "my_ip" {
  url = "https://ipv4.icanhazip.com"
}

# This resource generates a secure, random password for the RDS database.
# Using this ensures you don't have to hardcode or manually provide a password.
resource "random_password" "db_password" {
  length  = 16
  special = true
}

# This block instantiates the VPC module, which creates all the networking infrastructure
# (VPC, public/private subnets, route tables, internet gateway, etc.).
module "vpc" {
  source     = "../../modules/vpc"
  aws_region = var.aws_region
}

# This block instantiates the EC2 application server module.
module "ec2_app" {
  source = "../../modules/ec2_app"
  # Passes the VPC ID from the VPC module's output.
  vpc_id = module.vpc.vpc_id
  # Uses the ID of the first public subnet created by the VPC module for the EC2 instance.
  public_subnet_id = module.vpc.public_subnet_ids[0]
  # Passes your public IP (retrieved from the data source) to the module for the SSH ingress rule.
  # chomp() removes the trailing newline character from the HTTP response.
  my_ip_for_ssh = chomp(data.http.my_ip.response_body)

  # Defines the instance size.
  instance_type = "t2.micro"
  # The name of the EC2 Key Pair to use for SSH access.
  key_name = "vockey"
  # Passes the database endpoint address from the RDS module's output.
  db_endpoint = module.rds_db.db_endpoint
  # Passes the randomly generated password to the EC2 instance's user data script.
  db_password = random_password.db_password.result
}

# This block instantiates the RDS database module.
module "rds_db" {
  source = "../../modules/rds_db"
  # Passes the VPC ID from the VPC module's output.
  vpc_id = module.vpc.vpc_id
  # Provides the list of private subnet IDs from the VPC module. The database will be placed here for security.
  private_subnet_ids = module.vpc.private_subnet_ids
  # Passes the security group ID of the EC2 instance. This allows the database to accept connections from the app server.
  app_server_sg_id = module.ec2_app.security_group_id
  # Passes the randomly generated password to be set as the master password for the database.
  db_password = random_password.db_password.result
}
