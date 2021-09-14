variable "lambda_exe_arn" {
  description = "Security group id"
}

variable "sftp_dynamo_name" {
  description = "Sftp dynamo auth table"
}


variable "sftp_server_id" {
  description = "Sftp server id"
}

variable "account_id" {
  description = "AWS Account Id"
}

variable "aws_region" {
  description = "AWS Region."
}

variable "vpc_id" {
  description = "VPC Id"
}


variable "api_sg_id" {
  type        = list
  description = "API SG ID"
}

variable "subnetid" {
  description = "API SG ID"
}


#Header
variable "allowed_headers" {
  description = "Allowed headers"
  type        = list

  default = [
    "Content-Type",
    "X-Amz-Date",
    "Authorization",
    "X-Api-Key",
    "X-Amz-Security-Token",
  ]
}

variable "allowed_methods" {
  description = "Allowed methods"
  type        = list

  default = [
    "OPTIONS",
    "HEAD",
    "GET",
    "POST",
    "PUT",
    "PATCH",
    "DELETE",
  ]
}

variable "allowed_origin" {
  description = "Allowed origin"
  type        = string
  default     = "*"
}

variable "allowed_max_age" {
  description = "Allowed response caching time"
  type        = string
  default     = "7200"
}
