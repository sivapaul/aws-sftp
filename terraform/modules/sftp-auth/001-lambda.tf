##Lambda to add user to dynamo database
resource "aws_lambda_function" "sftp-manage-post" {
  filename         = "${path.module}/lambda/sftp-manage-post.zip"
  function_name    = "sftp_user_post"
  handler          = "index.handler"
  runtime          = "nodejs12.x"
  role             = var.lambda_exe_arn
  source_code_hash = data.archive_file.sftp-manage-post.output_base64sha256

  memory_size                    = 2048
  timeout                        = 900
  reserved_concurrent_executions = 3

  environment {
    variables = {
      DYNAMO_TABLE = "${var.sftp_dynamo_name}"
    }
  }
}

data "archive_file" "sftp-manage-post" {
  type        = "zip"
  source_dir  = "${path.module}/lambda/post"
  output_path = "${path.module}/lambda/sftp-manage-post.zip"
}

##Lambda to get users from dynamo database
resource "aws_lambda_function" "sftp-manage-get" {
  filename         = "${path.module}/lambda/sftp-manage-get.zip"
  function_name    = "sftp_user_get"
  handler          = "index.handler"
  runtime          = "nodejs12.x"
  role             = var.lambda_exe_arn
  source_code_hash = data.archive_file.sftp-manage-get.output_base64sha256

  memory_size                    = 2048
  timeout                        = 900
  reserved_concurrent_executions = 3

  environment {
    variables = {
      DYNAMO_TABLE = var.sftp_dynamo_name
    }
  }

}

data "archive_file" "sftp-manage-get" {
  type        = "zip"
  source_dir  = "${path.module}/lambda/get"
  output_path = "${path.module}/lambda/sftp-manage-get.zip"
}
