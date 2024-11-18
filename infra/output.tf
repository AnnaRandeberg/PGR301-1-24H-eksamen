#https://github.com/glennbechdevops/terraform-s3-website
#testing someting comment
output "sqs_queue_url" {
  description = "URL for the SQS Queue"
  value       = aws_sqs_queue.sqs_queue.id
}

output "lambda_function_arn" {
  description = "ARN for the Lambda function"
  value       = aws_lambda_function.sqs_lambda.arn
}

output "sqs_queue_arn" {
  description = "ARN for the SQS Queue"
  value       = aws_sqs_queue.sqs_queue.arn
}
