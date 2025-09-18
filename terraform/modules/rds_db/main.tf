# This resource defines a security group specifically for the RDS database instance.
resource "aws_security_group" "main" {
  # A unique name for the security group.
  name        = "TechStore-DB-SG"
  # A helpful description of the security group's purpose.
  description = "Security group for RDS DB instances"
  # Associates this security group with the specified VPC.
  vpc_id      = var.vpc_id

  # Defines an inbound rule for incoming traffic.
  ingress {
    description     = "Allow MySQL access from App Server"
    # The starting port for the MySQL protocol.
    from_port       = 3306
    # The ending port for the MySQL protocol.
    to_port         = 3306
    # The protocol for the traffic (TCP for database connections).
    protocol        = "tcp"
    # This is a crucial security measure. It only allows traffic from resources
    # within the specified application server security group, not from the open internet.
    security_groups = [var.app_server_sg_id]
  }

  # Defines an outbound rule for outgoing traffic.
  egress {
    # Allows traffic to any port.
    from_port   = 0
    to_port     = 0
    # Allows any protocol.
    protocol    = "-1"
    # Allows outbound traffic to any destination.
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Tags for easy identification of the security group in the AWS console.
  tags = {
    Name = "TechStore-DB-SG"
  }
}

# Creates a database subnet group. RDS instances are placed in this group,
# which tells RDS which subnets within the VPC it can use.
resource "aws_db_subnet_group" "main" {
    # A unique name for the DB subnet group.
    name = "techstore-db-subnet-group"
    # A list of subnet IDs. For security, these should be private subnets.
    subnet_ids = var.private_subnet_ids
    # Tags for identification.
    tags = {
      Name = "TechStore DB Subnet Group"  
    }
}

# This resource provisions the actual RDS database instance.
resource "aws_db_instance" "main" {
    # A unique identifier for the DB instance.
    identifier = "techstore-db"
    # The type of database engine to use.
    engine = "mysql"
    # The specific version of the database engine.
    engine_version = "8.4.6"
    # Specifies if the DB should be deployed across multiple Availability Zones for high availability.
    multi_az = false
    # The instance class that defines the compute and memory capacity of the DB instance.
    instance_class = "db.t3.micro"
    # The storage type for the database. "gp2" is General Purpose SSD.
    storage_type = "gp2"
    # The amount of storage to allocate in gigabytes.
    allocated_storage = 20
    # The username for the master database user.
    username = "admin"
    # The name of the initial database to be created when the DB instance is created.
    db_name = var.db_name
    # The password for the master database user, passed in as a variable.
    password = var.db_password
    # Associates the security group created above with this DB instance.
    vpc_security_group_ids = [aws_security_group.main.id]
    # Specifies the DB subnet group to be used by the DB instance.
    db_subnet_group_name = aws_db_subnet_group.main.name
    # If true, RDS will not create a final snapshot when the DB instance is deleted. (For dev/test).
    skip_final_snapshot = true
    # The number of days to retain automated backups. 0 disables automated backups.
    backup_retention_period = 0

    # Tags for identifying the database instance.
    tags = {
        Name = "TechStore-DB"
    }
}