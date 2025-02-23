output "arn" {
  description = "The ARN of the EventBridge API Destination"
  value = aws_cloudwatch_event_api_destination.destination.arn
}