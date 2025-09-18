# This variable stores the ID of the public subnet where the EC2 instance will be launched.
variable "public_subnet_id" {
  description = "The ID of the public subnet"
  type        = string
}

# This variable holds your public IP address to create a specific firewall rule for SSH access, enhancing security.
variable "my_ip_for_ssh" {
  description = "Your IP address for SSH access"
  type        = string
}

# This variable is for the ID of the VPC (Virtual Private Cloud) to ensure resources are created in the correct network.
variable "vpc_id" {
    description = "The ID of the VPC where the EC2 instance will be deployed"
    type        = string
}

# This variable defines the compute and memory capacity of the EC2 instance. It defaults to "t2.micro".
variable "instance_type" {
    description = "The type of instance to use for the EC2 instance"
    type = string
    default = "t2.micro"
}

# This variable sets the master username for the RDS database. Defaults to "admin".
variable "db_username" {
    description = "The name of the database to create"
    type        = string
    default = "admin"
  
}

# This variable defines the name for the initial database to be created inside the RDS instance.
variable "db_name" {
    description = "The name of the database to create"
    type        = string
    default = "techstoredb"
  
}

# This variable holds the master password for the RDS database. 
# 'sensitive = true' prevents Terraform from showing this value in logs or CLI output.
variable "db_password" {
    description = "The password for the RDS database master user"
    type        = string
    sensitive   = true
  
}

# This variable contains the connection endpoint (hostname) for the RDS database instance.
# It is also marked as 'sensitive' to protect it from being exposed in outputs.
variable "db_endpoint" {
    description = "The endpoint of the RDS database instance"
    type        = string
    sensitive = true
}

# This variable specifies the name of the EC2 Key Pair to be associated with the instance for SSH access.
variable "key_name" {
    description = "The name of the key pair"
    type       = string
}