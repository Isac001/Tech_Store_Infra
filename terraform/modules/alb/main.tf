# This resource defines a Security Group specifically for the Application Load Balancer (ALB).
# It controls the inbound and outbound traffic for the load balancer itself.
resource "aws_security_group" "main" {

  name        = "TechStore-ALB-SG"
  description = "Security group for Application Load Balancer"
  vpc_id      = var.vpc_id

  # Defines an inbound rule to allow traffic from the internet.
  ingress {

    # The description of the inbound rule.
    description = "Allow HTTP traffic"

    # Allows traffic on port 80, which is the standard port for HTTP.
    from_port = 80
    to_port   = 80
    protocol  = "tcp"

    # "0.0.0.0/0" allows traffic from any IP address on the internet.
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Defines an outbound rule for traffic leaving the load balancer.
  egress {
    description = "Allow all outbound traffic"

    # from_port = 0 and to_port = 0 with protocol = "-1" means all ports and protocols are allowed.
    from_port = 0
    to_port   = 0
    protocol  = "-1"

    # This allows the load balancer to forward traffic to the target instances on any port.
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Assigns tags to the security group for easy identification.
  tags = {
    Name = "TechStore-ALB-SG"
  }
}

# This resource creates the Application Load Balancer (ALB) itself.
resource "aws_lb" "main" {

  # The friendly name of the load balancer.
  name = "TechStore-ALB"

  # 'internal = false' makes this an internet-facing load balancer, accessible from the public internet.
  internal = false

  # Specifies that this is an Application Load Balancer, which operates at Layer 7 (the application layer).
  load_balancer_type = "application"

  # Associates the security group created above with this load balancer.
  security_groups = [aws_security_group.main.id]

  # Specifies the public subnets across which the load balancer will be deployed for high availability.
  subnets = var.public_subnet_ids

  # Assigns tags to the load balancer resource.
  tags = {
    Name = "TechStore-ALB"
  }
}

# This resource defines a listener for the ALB. A listener checks for connection requests
# from clients, based on the protocol and port that you configure.
resource "aws_lb_listener" "http" {

  # The ARN of the load balancer to which this listener will be attached.
  load_balancer_arn = aws_lb.main.arn

  # The port on which the listener will check for connections.
  port = 80

  # The protocol for connections from clients to the load balancer.
  protocol = "HTTP"

  # Defines the default action to take when a request is received that doesn't match any other rules.
  default_action {

    # "forward" sends the request to one or more target groups.
    type = "forward"

    # The ARN of the target group where the traffic will be forwarded.
    target_group_arn = var.target_group_arn
  }
}
