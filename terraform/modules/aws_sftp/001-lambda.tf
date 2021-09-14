resource "aws_lambda_function" "sftp-auth" {
  filename         = "${path.module}/lambda/sftp-auth.zip"
  function_name    = "sftp_auth"
  handler          = "index.handler"
  runtime          = "nodejs12.x"
  role             = aws_iam_role.iam_lambda_execution.arn
  source_code_hash = data.archive_file.sftp-idp.output_base64sha256

  memory_size                    = 2048
  timeout                        = 900
  reserved_concurrent_executions = 3

  environment {
    variables = {
      BUCKET_ARN   = aws_s3_bucket.sftp-sftps3.arn
      DYNAMO_TABLE = aws_dynamodb_table.sftp-auth.name
      ROLE_ARN     = aws_iam_role.sftp-auth-role.arn
      #SERVER_ID    = aws_transfer_server.dev-sftp.id
    }
  }
}

data "archive_file" "sftp-idp" {
  type        = "zip"
  source_dir  = "${path.module}/lambda/"
  output_path = "${path.module}/lambda/sftp-auth.zip"
}
