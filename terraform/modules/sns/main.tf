# This resource defines and creates an Amazon SNS (Simple Notification Service) topic.
# An SNS topic acts as a communication channel for sending messages to subscribers.
resource "aws_sns_topic" "main" {
  
  # The name of the SNS topic, provided by a variable for reusability.
  name = var.topic_name

  # Assigns tags to the SNS topic for better organization and identification within AWS.
  tags = {
    Name = var.topic_name
  }
}

# This resource creates a subscription to the SNS topic defined above.
# Subscribers will receive any messages published to this topic.
resource "aws_sns_topic_subscription" "main" {

  # The ARN (Amazon Resource Name) of the topic to which this subscription is being added.
  topic_arn = aws_sns_topic.main.arn

  # The protocol to use for the subscription. "email" means notifications will be sent as emails.
  protocol = "email"

  # The endpoint that will receive the notifications. For the "email" protocol, this is an email address.
  endpoint = var.subscription_endpoint
}
