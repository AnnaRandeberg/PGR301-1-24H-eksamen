#source: https://github.com/glennbechdevops/terraform-s3-website
variable "prefix" {
  description = "Resource name prefix"
  type        = string
  default     = "41"
}

variable "sqs_queue_name" {
  description = "SQS queue name"
  type        = string
  default     = "sqs-queue" 
}

#source: https://github.com/glennbechdevops/cloudwatch_alarms_terraform
variable "alarm_threshold" {
  description = "Threshold for the approximate age of the oldest message in the SQS queue (in seconds)."
  type        = number
  default     = 10 
}


variable "alarm_email" {
  description = "Email address to receive alarm notifications."
  type        = string
}

