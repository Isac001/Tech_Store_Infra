# Output the ARN of the SNS topic
output "topic_arn" {
    description = "The ARN of the SNS topic"
    value       = aws_sns_topic.main.arn
  
}