# Defines a security group for the main application instances.
resource "aws_security_group" "main" {

  # The name of the security group.
  name = "TechStore-EC2App-SG"

  # A description for the security group to identify its purpose.
  description = "Security group for EC2 App instances"

  # Associates the security group with a specific VPC.
  vpc_id = var.vpc_id

  # Defines an inbound rule for traffic.
  ingress {

    # The description of the inbound rule.
    description = "Allow SSH from my IP"

    # The starting port of the allowed range.
    from_port = 22

    # The ending port of the allowed range.
    to_port = 22

    # The protocol for the traffic (TCP in this case for SSH).
    protocol = "tcp"

    # A list of CIDR blocks that are allowed access. Here it's restricted to a specific IP for SSH.
    cidr_blocks = ["${var.my_ip_for_ssh}/32"]
  }

  # Defines another inbound rule.
  ingress {

    # The description of the inbound rule.
    description = "Allow access to the Flask from internet"

    # The port the Flask application will run on.
    from_port = 5000
    to_port   = 5000
    protocol  = "tcp"

    # Allows access from any IP address on the internet (0.0.0.0/0).
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Defines an outbound (outgoing) traffic rule.
  egress {

    # Allows traffic to any port.
    from_port = 0
    to_port   = 0

    # Allows any protocol ("-1" means all protocols).
    protocol = "-1"

    # Allows outbound traffic to any destination.
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Assigns tags to the security group for easy identification and management.
  tags = {
    Name = "TechStore-SG"
  }
}

# Data source to find the latest Amazon Linux 2023 AMI.
# This ensures the instance always uses the most up-to-date, patched version of the OS.
data "aws_ami" "amazon_linux" {

  # Specifies to select the most recent AMI that matches the filter.
  most_recent = true

  # Filters the AMIs owned by Amazon.
  owners = ["amazon"]

  # Filters AMIs based on their name to find the AL2023 for x86_64 architecture.
  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }
}

# Creates an EC2 instance resource.
# Note: This instance is for creating the initial AMI and testing. It's not part of the Auto Scaling Group itself.
resource "aws_instance" "main" {

  # The ID of the AMI to use for the instance, retrieved from the data source above.
  ami = data.aws_ami.amazon_linux.id

  # The type of instance to start (e.g., t2.micro, t3.small).
  instance_type = var.instance_type

  # The key pair to use for SSH access to the instance.
  key_name = var.key_name

  # The ID of the subnet to launch the instance into.
  subnet_id = var.public_subnet_id

  # A list of security group IDs to associate with the instance.
  vpc_security_group_ids = [aws_security_group.main.id]
  
  # Specifies whether to associate a public IP address with the instance.
  associate_public_ip_address = true

  # Provides user data to the instance, which is a script that runs on the first boot.
  # It uses a template file and passes variables for the database connection.
  user_data = templatefile("${path.module}/install_flask.sh.tpl", {
    db_endpoint = var.db_endpoint
    db_username = var.db_username
    db_password = var.db_password
    db_name     = var.db_name
  })

  # Assigns tags to the EC2 instance.
  tags = {
    Name = "TechStore-App-Server"
  }
}

# Defines a Launch Template for the Auto Scaling Group.
# This template specifies the configuration of EC2 instances that will be launched.
resource "aws_launch_template" "main" {

  # Sets a prefix for the launch template name, Terraform will add a unique suffix.
  name_prefix = "TechStore-Template-"
  
  # Specifies the Amazon Machine Image (AMI) to use for the instances.
  image_id = data.aws_ami.amazon_linux.id

  # Defines the instance size and type.
  instance_type = var.instance_type

  # The name of the key pair for SSH access.
  key_name = var.key_name

  # A list of security group IDs to apply to instances launched from this template.
  vpc_security_group_ids = [aws_security_group.main.id]

  # The user data script to run when an instance launches. It must be base64-encoded.
  user_data = base64encode(templatefile("${path.module}/install_flask.sh.tpl", {
    db_endpoint = var.db_endpoint
    db_username = var.db_username
    db_password = var.db_password
    db_name     = var.db_name
  }))

  # Defines tags that will be applied to instances launched using this template.
  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "TechStore-App-Server"
    }
  }

  # Lifecycle rule to prevent errors during updates by creating the new template before deleting the old one.
  lifecycle {
    create_before_destroy = true
  }
}

# Defines a Target Group for the Application Load Balancer.
# The Target Group is used to route requests to one or more registered targets, such as EC2 instances.
resource "aws_lb_target_group" "main" {

  # The name of the target group.
  name     = "TechStore-TG"

  # The port on which the targets receive traffic.
  port     = 5000

  # The protocol to use for routing traffic to the targets.
  protocol = "HTTP"

  # The ID of the VPC where the targets are located.
  vpc_id   = var.vpc_id
  
  # Specifies that the targets are EC2 instances.
  target_type = "instance"

  # Configures health checks for the targets in this group.
  health_check {

    # Enables the health check.
    enabled  = true

    # The destination for the health check requests.
    path     = "/health"

    # The protocol to use for the health check.
    protocol = "HTTP"

    # The HTTP status codes that indicate a healthy target.
    matcher  = "200"
  }

  # Assigns tags to the target group for easy identification.
  tags = {
    Name = "TechStore-TG"
  }
}