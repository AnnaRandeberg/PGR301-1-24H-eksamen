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
