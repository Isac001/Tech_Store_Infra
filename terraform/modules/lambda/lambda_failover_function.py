# File: modules/lambda/lambda_function.py
# This script contains the logic for an AWS Lambda function designed to test an Auto Scaling Group.

import os
import boto3
import random

# Initialize the AWS clients. The region is automatically inherited from the Lambda execution environment.
ec2 = boto3.client('ec2')
sns = boto3.client('sns')
autoscaling = boto3.client('autoscaling')

# Retrieve environment variables that are configured and passed by Terraform.
SNS_TOPIC_ARN = os.environ.get('SNS_TOPIC_ARN')
AUTOSCALING_GROUP_NAME = os.environ.get('AUTOSCALING_GROUP_NAME')

def lambda_handler(event, context):
    """
    This function tests the Auto Scaling Group by performing the following actions:
    1. Finds a healthy, in-service instance within the group.
    2. Terminates the selected instance to simulate a failure.
    3. Sends a notification to an SNS topic with the status of the operation.
    """
    # First, validate that the required environment variables were successfully passed to the function.
    if not AUTOSCALING_GROUP_NAME or not SNS_TOPIC_ARN:
        error_message = "Error: Environment variables AUTOSCALING_GROUP_NAME and SNS_TOPIC_ARN must be set."
        print(error_message)
        # Return an error status if configuration is missing.
        return {'statusCode': 500, 'body': error_message}

    try:
        # Get the details of the specified Auto Scaling Group.
        asg_response = autoscaling.describe_auto_scaling_groups(
            AutoScalingGroupNames=[AUTOSCALING_GROUP_NAME]
        )
        
        # Check if the Auto Scaling Group was found. If not, raise an error.
        if not asg_response['AutoScalingGroups']:
            raise ValueError(f"Auto Scaling Group '{AUTOSCALING_GROUP_NAME}' not found.")
            
        # Get the list of instances associated with the group.
        instances = asg_response['AutoScalingGroups'][0]['Instances']
        
        # Filter the list to include only instances that are healthy and in the 'InService' state.
        healthy_instances = [i for i in instances if i['LifecycleState'] == 'InService' and i['HealthStatus'] == 'Healthy']
        
        # If no healthy instances are found, there's nothing to terminate. Raise an error.
        if not healthy_instances:
            raise ValueError("No healthy instances found in the Auto Scaling Group to terminate.")

        # Randomly choose one of the healthy instances to terminate. This simulates a random failure.
        instance_to_terminate = random.choice(healthy_instances)
        instance_id_to_terminate = instance_to_terminate['InstanceId']
        
        print(f"Instance selected for termination: {instance_id_to_terminate}")
        
        # Terminate the chosen EC2 instance. This action will trigger the Auto Scaling Group to launch a replacement.
        ec2.terminate_instances(InstanceIds=[instance_id_to_terminate])
        
        # Prepare a success message for the SNS notification.
        message = f"""
        🔔 Auto Scaling Group Test Completed Successfully 🚀

        Action Performed:
        - Terminated instance to simulate failure: {instance_id_to_terminate}
        - Availability Zone: {instance_to_terminate['AvailabilityZone']}

        The Auto Scaling Group '{AUTOSCALING_GROUP_NAME}' will now detect this termination and launch a new instance to maintain the desired capacity.
        """

    except Exception as e:
        # If any error occurs during the 'try' block, catch it.
        print(f"An error occurred: {e}")
        # Prepare an error message for the SNS notification.
        message = f"🚨 ERROR while testing Auto Scaling Group '{AUTOSCALING_GROUP_NAME}':\n\n{str(e)}"

    # Publish the final result (whether success or error) to the specified SNS topic.
    sns.publish(
        TopicArn=SNS_TOPIC_ARN,
        Subject=f"Test Report - ASG TechStore",
        Message=message
    )
    
    # Return a success response to indicate that the Lambda function itself executed without crashing.
    return {
        'statusCode': 200,
        'body': 'Lambda function executed!'
    }