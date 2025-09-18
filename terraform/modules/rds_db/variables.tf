# This variable specifies the ID of the Virtual Private Cloud (VPC) where the RDS instance will be provisioned.
# All related resources, like subnets and security groups, must exist within this VPC.
variable "vpc_id" {
  description = "The ID of the VPC where the RDS instance will be deployed"
  type        = string
}

# This variable takes a list of private subnet IDs. RDS will place the database instance
# within these subnets, which is a security best practice as it prevents direct public access.
variable "private_subnet_ids" {
  description = "The ID of the subnet where the RDS instance will be deployed"
  type        = list(string)
}

# This variable holds the ID of the EC2 application server's security group.
# It is used to create a specific firewall rule, allowing the app server to connect to the database.
variable "app_server_sg_id" {
  description = "The security group ID of the application server that will access the RDS instance"
  type        = string
}

# This variable stores the password for the database's master user.
# It is marked as 'sensitive' to prevent Terraform from displaying it in plain text in console outputs or logs.
variable "db_password" {
  description = "The password for the RDS database master user"
  type        = string
  sensitive   = true
}

# This variable defines the name for the initial database schema created when the RDS instance is first set up.
# It has a default value of "techstoredb" but can be overridden.
variable "db_name" {
  description = "The name of the database to create"
  type        = string
  default     = "techstoredb"  
}
