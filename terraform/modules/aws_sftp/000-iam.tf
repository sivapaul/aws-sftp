## LambdaExecutionRole Start

resource "aws_iam_role" "iam_lambda_execution" {
  name = "iam_lambda_execution"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "role_attach_lambdaexecute" {
  role       = aws_iam_role.iam_lambda_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "role_attach_lambdavpc" {
  role       = aws_iam_role.iam_lambda_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

resource "aws_iam_role_policy_attachment" "role_attach_dynamo" {
  role       = aws_iam_role.iam_lambda_execution.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"
}

resource "aws_iam_role_policy_attachment" "role_attach_s3" {
  role       = aws_iam_role.iam_lambda_execution.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

## LambdaExecutionRole End
## TransferIdentityProviderRole Start

resource "aws_iam_role" "iam_sftp_identity" {
  name               = "iam_sftp_identity"
  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
        "Effect": "Allow",
        "Principal": {
            "Service": "transfer.amazonaws.com"
        },
        "Action": "sts:AssumeRole"
        }
    ]
}
EOF
}

resource "aws_iam_role_policy" "policy_invoke" {
  name = "policy_invoke"
  role = aws_iam_role.iam_sftp_identity.id

  policy = <<POLICY
{
        "Version": "2012-10-17",
        "Statement": [
                {
                        "Sid": "InvokeApi",
                        "Effect": "Allow",
                        "Action": [
                                "execute-api:Invoke"
                        ],
                        "Resource": "arn:aws:execute-api:${var.aws_region}:${var.account_id}:*/prod/GET/*"
                },
                {
                        "Sid": "ReadApi",
                        "Effect": "Allow",
                        "Action": [
                                "apigateway:GET"
                        ],
                        "Resource": "*"
                }
        ]
}
POLICY
}
## TransferIdentityProviderRole End

## SFTP Log Role Start
resource "aws_iam_role" "iam_sftp_log" {
  name = "iam_sftp_log"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
        "Effect": "Allow",
        "Principal": {
            "Service": "transfer.amazonaws.com"
        },
        "Action": "sts:AssumeRole"
        }
    ]
}
EOF
}

resource "aws_iam_role_policy" "iam_sftp_log" {
  name = "iam-sftp-log-policy"
  role = aws_iam_role.iam_sftp_log.id

  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
        "Sid": "AllowFullAccesstoCloudWatchLogs",
        "Effect": "Allow",
        "Action": [
            "logs:*"
        ],
        "Resource": "*"
        }
    ]
}
POLICY
}
## SFTP Log Role End

## Bucket Role for SFTP identity Start

resource "aws_iam_role" "sftp-auth-role" {
  name = "transfer-iam-role"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
        "Effect": "Allow",
        "Principal": {
            "Service": "transfer.amazonaws.com"
        },
        "Action": "sts:AssumeRole"
        }
    ]
}
EOF
}

resource "aws_iam_role_policy" "sftp-policy" {
  name = "transfer-user-iam-policy"
  role = aws_iam_role.sftp-auth-role.id

  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AllowFullAccesstoS3",
            "Effect": "Allow",
            "Action": [
                "s3:*"
            ],
            "Resource": "arn:aws:s3:::*"
        }
    ]
}
POLICY
}


## Bucket Role for SFTP identity End
##Bucket Role for S3 Access to sftp
resource "aws_iam_user" "sftp-s3access" {
  name = "sftp-s3access"

}

resource "aws_iam_policy" "sftp-s3access-policy" {
  name = "sftp-s3access-policy"
  policy = jsonencode({
    "Statement": [
        {
            "Action": [
                "s3:*"
            ],
            "Effect": "Allow",
            "Resource": [
                "arn:aws:s3:::${aws_s3_bucket.sftp-sftps3.bucket_domain_name}",
                "arn:aws:s3:::${aws_s3_bucket.sftp-sftps3.bucket_domain_name}/*"
            ],
            "Sid": "AllowFullAccesstoS3"
        }
    ],
    "Version": "2012-10-17"
})
}

resource "aws_iam_user_policy_attachment" "sftp-s3access-policy" {
  user = aws_iam_user.sftp-s3access.name
  policy_arn = aws_iam_policy.sftp-s3access-policy.arn
}
