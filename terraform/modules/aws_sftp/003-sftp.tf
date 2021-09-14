# Module      : AWS TRANSFER SERVER
# Description : Provides a AWS Transfer Server resource.
resource "aws_transfer_server" "dev-sftp" {

  identity_provider_type = "API_GATEWAY"
#  endpoint_type          = var.endpoint_type

# Enable below if you need to setup sftp for internal within VPC
#  endpoint_details {
#    vpc_id     = var.vpc_id
#    subnet_ids = var.subnet_ids
#  }



  logging_role    = aws_iam_role.iam_sftp_log.arn
  url             = aws_api_gateway_deployment.prod.invoke_url
  invocation_role = aws_iam_role.iam_sftp_identity.arn

  tags = {
    Name = "sftp-server"
  }

}


# #Dynamo database for user auth
resource "aws_dynamodb_table" "sftp-auth" {
  name           = var.dynamo_table_name
  billing_mode   = "PROVISIONED"
  read_capacity  = 20
  write_capacity = 20
  hash_key       = "username"

  point_in_time_recovery {
    enabled = true
  }

  attribute {
    name = "username"
    type = "S"
  }

  tags = {
    Name      = var.dynamo_table_name
    Terraform = "true"
  }
}
