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


resource "aws_launch_template" "main" {

  name_prefix            = "TechStore-Template-"
  image_id               = data.aws_ami.amazon_linux.id
  instance_type          = var.instance_type
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.main.id]

  user_data = base64encode(templatefile("${path.module}/install_flask.sh.tpl", {
    db_endpoint = var.db_endpoint
    db_username = var.db_username
    db_password = var.db_password
    db_name     = var.db_name
  }))

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "TechStore-App-Server"
    }
  }

  lifecycle {
    create_before_destroy = true
  }

}

resource "aws_lb_target_group" "main" {
  name        = "TechStore-TG"
  port        = 5000
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "instance"

  health_check {
    enabled  = true
    path     = "/health"
    protocol = "HTTP"
    matcher  = "200"
  }

  tags = {
    Name = "TechStore-TG"
  }
}
