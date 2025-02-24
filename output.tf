output "arn" {
  description = "The ARN of the EventBridge API Destination."
  value       = aws_cloudwatch_event_api_destination.destination.arn
}

output "iam_role_arn" {
  description = "The ARN of the IAM Role that allows EventBridge to invoke the API Destination."
  value       = aws_iam_role.invoke_api_dest.arn
}
