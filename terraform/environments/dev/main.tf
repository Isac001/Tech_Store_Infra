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

# This resource creates a custom CloudWatch Dashboard to monitor the application's key metrics.
resource "aws_cloudwatch_dashboard" "main" {

  # The name that will appear on the CloudWatch Dashboard.
  dashboard_name = "TechStore-Dashboard"

  # The body of the dashboard is defined in a JSON template file.
  # This makes the dashboard definition cleaner and reusable.
  dashboard_body = templatefile("${path.module}/dashboard.json.tpl", {

    # Passes required variables to the template to build the correct metric widgets.
    aws_region        = var.aws_region
    tg_name           = module.ec2_app.target_group_name
    asg_name          = module.autoscaling.autoscaling_group_name
    alb_name          = split("/", module.alb.load_balancer_name)[0]
    rds_db_identifier = module.rds_db.db_instance_identifier

  })
}

# This block instantiates the VPC module, which creates all the networking infrastructure
# (VPC, public/private subnets, route tables, internet gateway, etc.).
module "vpc" {
  # The path to the VPC module.
  source = "../../modules/vpc"

  # The Region where the VPC will be created.
  aws_region = var.aws_region
}

# This block instantiates the EC2 application server module. It defines the initial server,
# its security group, and the launch template for the Auto Scaling Group.
module "ec2_app" {
  # The path to the EC2 application server module.
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
  # The path to the RDS module.
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

# This block instantiates the Application Load Balancer (ALB) module.
module "alb" {
  # The path to the ALB module.
  source = "../../modules/alb"

  # The VPC where the ALB will be deployed.
  vpc_id = module.vpc.vpc_id

  # A list of public subnets for the ALB to operate in for high availability.
  public_subnet_ids = module.vpc.public_subnet_ids

  # The target group (created in the ec2_app module) where the ALB will forward traffic.
  target_group_arn = module.ec2_app.target_group_arn
}

# This block instantiates the Auto Scaling module.
module "autoscaling" {

  # The path to the Auto Scaling module.
  source = "../../modules/autoscaling"

  # The launch template (from the ec2_app module) that defines what kind of instances to create.
  launch_template_id = module.ec2_app.launch_template_id

  # The target group where new instances will be registered.
  target_group_arn = module.ec2_app.target_group_arn

  # The subnets where new instances can be launched.
  public_subnet_ids = module.vpc.public_subnet_ids
}

# This block instantiates the SNS module to create a topic for notifications.
module "sns" {
  # The path to the SNS module.
  source = "../../modules/sns"

  # Defines the name for the SNS topic.
  topic_name = "TechStore-EC2-Alerts"

  # The email address that will receive the notifications from this topic.
  subscription_endpoint = var.notification_email
}

# This block instantiates the Lambda function module.
# This function is used to test the Auto Scaling functionality.
module "lambda_alerts" {
  # The path to the Lambda module.
  source = "../../modules/lambda"

  # The name for the Lambda function.
  function_name = "TechStore-ASG-Test-Function"

  # The AWS region where the function will be deployed.
  aws_region = var.aws_region

  # The SNS topic to which the function will send its reports.
  sns_topic_arn = module.sns.topic_arn

  # The name of the Auto Scaling Group that the function will target for testing.
  autoscaling_group_name = module.autoscaling.autoscaling_group_name
}
