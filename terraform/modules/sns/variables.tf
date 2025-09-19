# Defines the name for the SNS topic to be created.
variable "topic_name" {
    description = "The name of the SNS topic."
    type        = string
}

# The destination endpoint for the SNS subscription (e.g., an email address).
variable "subscription_endpoint" {
    description = "The endpoint to receive notifications (e.g., an email address)."
    type        = string
}