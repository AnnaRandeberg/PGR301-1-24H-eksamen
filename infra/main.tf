#endring i main for å teste om terraform plan funker!!
#endring
#source: https://github.com/glennbechdevops/terraform-state/blob/main/lambda.tf
resource "aws_iam_role" "lambda_exec_role" {
  assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": "sts:AssumeRole",
        "Effect": "Allow",
        "Principal": {
          "Service": "lambda.amazonaws.com"
        }
      }
    ]
  })

  name = "${var.prefix}_lambda_exec_role"
}


resource "aws_iam_role_policy" "lambda_sqs_s3_policy" {
  name = "${var.prefix}_LambdaSQSS3Policy"
  role = aws_iam_role.lambda_exec_role.id

  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": [
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes",
          "sqs:SendMessage"
        ],
        "Resource": "*"
      },
      {
        "Effect": "Allow",
        "Action": [
          "s3:PutObject",
          "s3:GetObject"
        ],
        "Resource": "arn:aws:s3:::pgr301-couch-explorers/*"
     },
      {
        "Effect": "Allow",
        "Action": [
          "bedrock:InvokeModel"
        ],
        "Resource": "arn:aws:bedrock:us-east-1::foundation-model/amazon.titan-image-generator-v1"
      }
    ]
  })
}


resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}


resource "aws_lambda_function" "sqs_lambda" {
  function_name = "${var.prefix}_sqs_lambda_function"
  runtime       = "python3.9"
  handler       = "lambda_sqs.lambda_handler"
  role          = aws_iam_role.lambda_exec_role.arn
  filename      = "lambda_function_payload.zip"

  environment {
    variables = {
      BUCKET_NAME = "pgr301-couch-explorers"
      CANDIDATE_NR = "41"
    }
  }

  timeout = 30
}


resource "aws_sqs_queue" "sqs_queue" {
  name = "${var.prefix}-image-queue"
}


resource "aws_lambda_event_source_mapping" "sqs_event_source" {
  event_source_arn = aws_sqs_queue.sqs_queue.arn
  function_name    = aws_lambda_function.sqs_lambda.arn
  batch_size       = 10
  enabled          = true
}


data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "${path.module}/lambda_sqs.py"
  output_path = "${path.module}/lambda_function_payload.zip"
}



#source: https://github.com/glennbechdevops/cloudwatch_alarms_terraform
# CloudWatch Alarm for SQS ApproximateAgeOfOldestMessage
resource "aws_cloudwatch_metric_alarm" "sqs_oldest_message_age" {
  alarm_name          = "${var.prefix}-sqs-oldest-message-age"
  namespace           = "AWS/SQS"
  metric_name         = "ApproximateAgeOfOldestMessage"
  dimensions = {
    QueueName = aws_sqs_queue.sqs_queue.name
  }
  comparison_operator = "GreaterThanThreshold"
  threshold           = var.alarm_threshold 
  evaluation_periods  = 1 #endret denne til 1 for å teste alarmen min
  period              = 60 
  statistic           = "Maximum"
  
  alarm_description   = "Triggered when the age of the oldest message in the SQS queue exceeds the threshold."
  alarm_actions       = [aws_sns_topic.sqs_alarm_topic.arn]
}

resource "aws_sns_topic" "sqs_alarm_topic" {
  name = "${var.prefix}-sqs-alarm-topic"
}

resource "aws_sns_topic_subscription" "sqs_alarm_email_subscription" {
  topic_arn = aws_sns_topic.sqs_alarm_topic.arn
  protocol  = "email"
  endpoint  = var.alarm_email  
}
