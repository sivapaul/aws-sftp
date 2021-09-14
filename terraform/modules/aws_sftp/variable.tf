
variable "dynamo_table_name" {
  description = "Dynamo table name for authentication"
  type        = string
}

variable "subnet_ids" {
  type = list(string)
  default = []
}


variable "account" {
  description = "The 3 letter code for the AWS account"
  default     = "DEV"
}


variable "account_id" {
  description = "AWS Account Id"
  default     = "040196670356"
}

variable "aws_region" {
  description = "AWS Region."
}

variable "method" {
  description = "The HTTP method"
  default     = "GET"
}

variable "endpoint_type" {
  type        = string
  default     = "VPC"
  description = "The type of endpoint that you want your SFTP server connect to. If you connect to a VPC (or VPC_ENDPOINT), your SFTP server isn't accessible over the public internet. If you want to connect your SFTP server via public internet, set PUBLIC. Defaults to PUBLIC"
}

variable "vpc_id" {
  type        = string
  default     = ""
  description = "VPC ID"
}

#Module      : SFTP
#Description : Terraform sftp module variables.
variable "enable_sftp" {
  type        = bool
  default     = true
  description = "Set to false to prevent the module from creating any resources."
}