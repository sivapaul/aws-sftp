
resource "aws_api_gateway_rest_api" "sftp-auth" {
  name        = "sftp-auth"
  description = "This API provides an IDP for AWS Transfer service"
  endpoint_configuration {
    types = ["EDGE"]
  }
  depends_on = [aws_lambda_function.sftp-auth]
}

resource "aws_api_gateway_deployment" "prod" {
  rest_api_id = aws_api_gateway_rest_api.sftp-auth.id
  stage_name  = "prod"
#  variables = {
#    deployed_at = "${timestamp()}"
#  }

  depends_on = [
    aws_api_gateway_integration_response.sftp-auth-method-IntegrationResponse
  ]


  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_resource" "sftp-auth-resource-config" {
  rest_api_id = aws_api_gateway_rest_api.sftp-auth.id
  parent_id   = aws_api_gateway_resource.sftp-auth-resource-username.id
  path_part   = "config"
}

resource "aws_api_gateway_resource" "sftp-auth-resource-username" {
  rest_api_id = aws_api_gateway_rest_api.sftp-auth.id
  parent_id   = aws_api_gateway_resource.sftp-auth-resource-users.id
  path_part   = "{username}"
}

resource "aws_api_gateway_resource" "sftp-auth-resource-users" {
  rest_api_id = aws_api_gateway_rest_api.sftp-auth.id
  parent_id   = aws_api_gateway_resource.sftp-auth-resource-serverid.id
  path_part   = "users"
}

resource "aws_api_gateway_resource" "sftp-auth-resource-serverid" {
  rest_api_id = aws_api_gateway_rest_api.sftp-auth.id
  parent_id   = aws_api_gateway_resource.sftp-auth-resource-servers.id
  path_part   = "{serverId}"
}
resource "aws_api_gateway_resource" "sftp-auth-resource-servers" {
  rest_api_id = aws_api_gateway_rest_api.sftp-auth.id
  parent_id   = aws_api_gateway_rest_api.sftp-auth.root_resource_id
  path_part   = "servers"
}

resource "aws_api_gateway_method" "sftp-auth-method" {
  rest_api_id   = aws_api_gateway_rest_api.sftp-auth.id
  resource_id   = aws_api_gateway_resource.sftp-auth-resource-config.id
  http_method   = var.method
  authorization = "AWS_IAM"
  request_parameters = {
    "method.request.header.Password" = "false"
  }
}


resource "aws_api_gateway_integration" "sftp-auth-integration" {
  rest_api_id             = aws_api_gateway_rest_api.sftp-auth.id
  resource_id             = aws_api_gateway_resource.sftp-auth-resource-config.id
  http_method             = aws_api_gateway_method.sftp-auth-method.http_method
  integration_http_method = "POST"
  type                    = "AWS"
  uri                     = aws_lambda_function.sftp-auth.invoke_arn

  # Transforms the incoming XML request to JSON
  request_templates = {
    "application/json" = <<EOF
{
  "username": "$input.params('username')",
  "password": "$input.params('Password')",
  "serverId": "$input.params('serverId')"
}
EOF
  }
}

resource "aws_api_gateway_method_response" "sftp-auth-response_200" {
  rest_api_id = aws_api_gateway_rest_api.sftp-auth.id
  resource_id = aws_api_gateway_resource.sftp-auth-resource-config.id
  http_method = aws_api_gateway_method.sftp-auth-method.http_method
  status_code = 200
  depends_on = [
    null_resource.method-delay
  ]

  response_models = {
    "application/json" = aws_api_gateway_model.sftp-auth-model.name
  }
}

resource "aws_api_gateway_integration_response" "sftp-auth-method-IntegrationResponse" {
  rest_api_id = aws_api_gateway_rest_api.sftp-auth.id
  resource_id = aws_api_gateway_resource.sftp-auth-resource-config.id
  http_method = aws_api_gateway_method.sftp-auth-method.http_method
  status_code = aws_api_gateway_method_response.sftp-auth-response_200.status_code

  response_templates = {
    "application/json" = ""
  }

  depends_on = [
    null_resource.method-delay
  ]
}

resource "aws_api_gateway_model" "sftp-auth-model" {
  rest_api_id  = aws_api_gateway_rest_api.sftp-auth.id
  name         = "UserConfigResponseModel"
  description  = "API response for GetUserConfig"
  content_type = "application/json"

  schema = <<EOF
{
  "$schema": "http://json-schema.org/draft-04/schema#",
  "title": "UserUserConfig",
  "type": "object",
  "properties" : {
    "HomeDirectory": {"type": "string"},
    "HomeBucket": {"type": "string"},
    "Policy": {"type": "string"},
    "PublicKeys": {"type": "array", "items" : {"type" : "string"}},
    "Role": {"type": "string"}
  }
}
EOF
}

resource "aws_lambda_permission" "allow_apigateway" {
  statement_id  = "AllowExecutionFromApigateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.sftp-auth.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.sftp-auth.execution_arn}/*/GET/servers/*/users/*/config"
  depends_on = [
    null_resource.method-delay
  ]
}

resource "null_resource" "method-delay" {
  provisioner "local-exec" {
    command = "start-sleep 60"
    interpreter = ["PowerShell", "-Command"]
  }
  triggers = {
    response = "aws_api_gateway_resource.sftp-auth-resource-servers.id"
  }
}
