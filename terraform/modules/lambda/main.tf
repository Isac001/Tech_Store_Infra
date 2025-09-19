# This data source creates a zip archive of the Lambda function's Python source code.
# Terraform will use this zip file to deploy the function.
data "archive_file" "lambda_zip" {

  # Specifies that the output should be a zip file.
  type = "zip"

  # The path to the source Python file that contains the Lambda handler.
  source_file = "${path.module}/lambda_failover_function.py"

  # The path where the generated zip file will be stored.
  output_path = "${path.module}/lambda_failover_function.zip"
}

# This data source retrieves information about an existing IAM role.
# It's used here to get the ARN of a predefined role that the Lambda function will assume for its permissions.
data "aws_iam_role" "lab_user" {

  # The name of the existing IAM role to look up.
  name = "LabRole"

}

# This resource defines the AWS Lambda function itself.
resource "aws_lambda_function" "main" {

  # Sets the name of the Lambda function using a variable for flexibility.
  function_name = var.function_name

  # The Amazon Resource Name (ARN) of the IAM role that Lambda assumes when it executes the function.
  # Permissions for the function (e.g., to interact with EC2 or SNS) are defined in this role.
  role = data.aws_iam_role.lab_user.arn

  # The function entry point in your code. Format is "filename.handler_function_name".
  handler = "lambda_failover_function.lambda_handler"

  # The runtime environment for the Lambda function.
  runtime = "python3.9"

  # The maximum amount of time, in seconds, that the function is allowed to run.
  timeout = 30

  # A hash of the deployment package. Terraform uses this to detect if the code has changed and needs to be redeployed.
  source_code_hash = data.archive_file.lambda_zip.output_base64sha26

  # The path to the function's deployment package (the .zip file created earlier).
  filename = data.archive_file.lambda_zip.output_path

  # Defines environment variables that will be available to the function code at runtime.
  environment {
    variables = {
      # Passes the name of the Auto Scaling group as an environment variable.
      AUTOSCALING_GROUP_NAME = var.autoscaling_group_name

      # Passes the ARN of the SNS topic for sending notifications.
      SNS_TOPIC_ARN = var.sns_topic_arn
    }
  }

  # Assigns tags to the Lambda function for organization and cost tracking.
  tags = {
    Name = var.function_name
  }

}
