output "sftp_s3_arn" {
  value       = aws_s3_bucket.sftp-sftps3.arn
  description = "S3 bucket to hold AWS SFTP."
}

output "sftp_server_id" {
  value       = aws_transfer_server.dev-sftp.id
  description = "SFTP server name"
}

output "sftp_dynamo_name" {
  value       = aws_dynamodb_table.sftp-auth.name
  description = "SFTP Dynamo table name"
}

output "sftp_lambda_exe_arn" {
  value       = aws_iam_role.iam_lambda_execution.arn
  description = "SFTP lambda execution role"
}

output "api_sg_id" {
  value       = aws_security_group.sg_rol_sftp_manage.id
  description = "SFTP lambda execution role"
}
