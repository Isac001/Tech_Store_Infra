# This resource defines an Auto Scaling Group (ASG) that automatically manages
# the number of EC2 instances to meet the application's demand.
resource "aws_autoscaling_group" "main" {

  # Creates a unique name for the Auto Scaling Group by starting with this prefix.
  # AWS will append a unique string to it.
  name_prefix = "TechStore-ASG-"

  # The desired number of instances that the group should maintain at all times.
  desired_capacity = 1

  # The minimum number of instances the group can have. It won't scale in below this number.
  min_size = 1

  # The maximum number of instances the group can have. It won't scale out beyond this number.
  max_size = 4

  # A list of subnet IDs where the Auto Scaling Group can launch new instances.
  vpc_zone_identifier = var.public_subnet_ids

  # Specifies the launch template to be used for creating new instances.
  launch_template {
    # The ID of the launch template, which contains the instance configuration (AMI, instance type, etc.).
    id = var.launch_template_id
  }

  # A list of ARNs of the target groups to associate with the Auto Scaling Group.
  # New instances will be automatically registered with these load balancer target groups.
  target_group_arns = [var.target_group_arn]

  # Determines how instance health is checked. "ELB" uses the health checks from the associated Elastic Load Balancer.
  health_check_type = "ELB"

  # The amount of time, in seconds, that Auto Scaling waits after an instance comes into service
  # before checking its health status.
  health_check_grace_period = 300

  # Configures how the Auto Scaling group handles instance updates (e.g., when the launch template changes).
  instance_refresh {

    # "Rolling" replaces instances in batches to minimize or avoid downtime during an update.
    strategy = "Rolling"

  }

  # Defines a tag that will be applied to all instances launched by this Auto Scaling Group.
  tag {

    key   = "Name"
    value = "TechStore-App-Server"

    # If true, this tag will be added to each instance as it is launched.
    propagate_at_launch = true
  }
}
