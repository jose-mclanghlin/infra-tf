variable "aws_region" {
  description = "The AWS region to use. Allowed values: us-east-1 (N. Virginia), us-west-1 (N. California), us-west-2 (Oregon)."
  type        = string
  default     = "us-east-1"
  validation {
    condition     = contains(["us-east-1", "us-west-1", "us-west-2"], var.aws_region)
    error_message = "Region must be us-east-1 (N. Virginia), us-west-1 (N. California), or us-west-2 (Oregon)."
  }
}