/* API Creation start */
resource "aws_api_gateway_rest_api" "sftp-manage" {
  name        = "sftp-prod-manage"
  description = "This API to manage sftp server autentication."
  endpoint_configuration {
    types = ["EDGE"]
  }
}

resource "aws_api_gateway_authorizer" "sftp-manage" {
  name                   = "CognitoUserPoolAuthorizer"
  type                   = "COGNITO_USER_POOLS"
  rest_api_id            = aws_api_gateway_rest_api.sftp-manage.id
  authorizer_credentials = var.lambda_exe_arn
  provider_arns          = ["${aws_cognito_user_pool.auth.arn}"]
}

resource "aws_api_gateway_resource" "sftp-manage-root" {
  rest_api_id = aws_api_gateway_rest_api.sftp-manage.id
  parent_id   = aws_api_gateway_rest_api.sftp-manage.root_resource_id
  path_part   = "sftp-man"
}

# -------------------------------------------------------------
# Enable CORS
# This requires an OPTIONS method to be created
# -------------------------------------------------------------
resource "aws_api_gateway_method" "CORS" {
  rest_api_id   = aws_api_gateway_rest_api.sftp-manage.id
  resource_id   = aws_api_gateway_resource.sftp-manage-root.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "CORS" {
  rest_api_id   = aws_api_gateway_rest_api.sftp-manage.id
  resource_id   = aws_api_gateway_resource.sftp-manage-root.id
  http_method = aws_api_gateway_method.CORS.http_method

  type = "MOCK"

  request_templates = {
    "application/json" = "{ \"statusCode\": 200 }"
  }
}

resource "aws_api_gateway_integration_response" "CORS" {
  rest_api_id   = aws_api_gateway_rest_api.sftp-manage.id
  resource_id   = aws_api_gateway_resource.sftp-manage-root.id
  http_method = aws_api_gateway_method.CORS.http_method
  status_code = 200

 response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'${join(",", var.allowed_headers)}'"
    "method.response.header.Access-Control-Allow-Methods" = "'${join(",", var.allowed_methods)}'"
    "method.response.header.Access-Control-Allow-Origin"  = "'${var.allowed_origin}'"
  }

  depends_on = [
    aws_api_gateway_integration.CORS,
  ]
}


resource "aws_api_gateway_method_response" "CORS" {
  rest_api_id   = aws_api_gateway_rest_api.sftp-manage.id
  resource_id   = aws_api_gateway_resource.sftp-manage-root.id
  http_method = aws_api_gateway_method.CORS.http_method
  status_code = 200

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Origin"  = true
  }

  response_models = {
    "application/json" = "Empty"
  }

  depends_on = [
    aws_api_gateway_method.CORS,
  ]
}

# ----------------------------------------------------
# "sftp-manage" method for the resource
# -----------------------------------------------------
resource "aws_api_gateway_method" "sftp-manage-post-method" {
  rest_api_id   = aws_api_gateway_rest_api.sftp-manage.id
  resource_id   = aws_api_gateway_resource.sftp-manage-root.id
  http_method   = "POST"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.sftp-manage.id
}

resource "aws_api_gateway_request_validator" "request_validator" {
  name = "Validate body"
  rest_api_id   = aws_api_gateway_rest_api.sftp-manage.id
  validate_request_body = true
  validate_request_parameters = false
}

resource "aws_api_gateway_integration" "sftp-manage-integration" {
  rest_api_id             = aws_api_gateway_rest_api.sftp-manage.id
  resource_id             = aws_api_gateway_resource.sftp-manage-root.id
  http_method             = aws_api_gateway_method.sftp-manage-post-method.http_method
  integration_http_method = "POST"
  type                    = "AWS"
  uri                     = aws_lambda_function.sftp-manage-post.invoke_arn

  request_templates = {
    "application/json" = <<EOF
#set($inputRoot = $input.path('$'))
{ 
"username": "$inputRoot.username",
"password": "$inputRoot.password",
"publickey": "$inputRoot.publickey",
"accountseq": "$inputRoot.accountseq"
}
EOF
  }

}

resource "aws_api_gateway_integration_response" "sftp-manage-IntegrationResponse" {
  rest_api_id             = aws_api_gateway_rest_api.sftp-manage.id
  resource_id             = aws_api_gateway_resource.sftp-manage-root.id
  http_method             = aws_api_gateway_method.sftp-manage-post-method.http_method
  status_code = 200

    depends_on = [
    aws_api_gateway_integration.sftp-manage-integration,
  ]

}

resource "aws_lambda_permission" "allow_apigateway" {
  statement_id  = "AllowExecutionFromApigateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.sftp-manage-post.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.sftp-manage.execution_arn}/*/POST/sftp-manage/*"
}


resource "aws_api_gateway_method_response" "sftp-manage" {
  rest_api_id   = aws_api_gateway_rest_api.sftp-manage.id
  resource_id   = aws_api_gateway_resource.sftp-manage-root.id
  http_method = aws_api_gateway_method.sftp-manage-post-method.http_method
  status_code = 200

  response_models = {
    "application/json" = "Empty"
  }

  depends_on = [
    aws_api_gateway_method.sftp-manage-post-method
  ]
}

#---------------------------------------



# ----------------------------------------------------
# "sftp-manage" method for the resource
# -----------------------------------------------------
resource "aws_api_gateway_method" "sftp-manage-get-method" {
  rest_api_id   = aws_api_gateway_rest_api.sftp-manage.id
  resource_id   = aws_api_gateway_resource.sftp-manage-root.id
  http_method   = "GET"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.sftp-manage.id
}


resource "aws_api_gateway_integration" "sftp-manage-get-integration" {
  rest_api_id             = aws_api_gateway_rest_api.sftp-manage.id
  resource_id             = aws_api_gateway_resource.sftp-manage-root.id
  http_method             = aws_api_gateway_method.sftp-manage-get-method.http_method
  integration_http_method = "GET"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.sftp-manage-get.invoke_arn

}

resource "aws_api_gateway_integration_response" "sftp-manage-get-IntegrationResponse" {
  rest_api_id             = aws_api_gateway_rest_api.sftp-manage.id
  resource_id             = aws_api_gateway_resource.sftp-manage-root.id
  http_method             = aws_api_gateway_method.sftp-manage-get-method.http_method
  status_code = 200

  depends_on = [
    aws_api_gateway_integration.sftp-manage-get-integration,
  ]
}

resource "aws_lambda_permission" "allow_apigateway_get" {
  statement_id  = "AllowExecutionFromApigateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.sftp-manage-get.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.sftp-manage.execution_arn}/*/GET/sftp-manage/*"
}


resource "aws_api_gateway_method_response" "sftp-manage-get" {
  rest_api_id   = aws_api_gateway_rest_api.sftp-manage.id
  resource_id   = aws_api_gateway_resource.sftp-manage-root.id
  http_method = aws_api_gateway_method.sftp-manage-get-method.http_method
  status_code = aws_api_gateway_integration_response.sftp-manage-get-IntegrationResponse.status_code

  response_models = {
    "application/json" = "Empty"
  }

  depends_on = [
    aws_api_gateway_method.sftp-manage-get-method
  ]
}

#---------------------------------------


resource "aws_api_gateway_model" "sftp-manage-model" {
  rest_api_id  = aws_api_gateway_rest_api.sftp-manage.id
  name         = "SftpData"
  description  = "API response for SftpData"
  content_type = "application/json"

  schema = <<EOF
{
  "type" : "object",
  "required" : [ "password", "publickey", "username", "accountseq" ],
  "properties" : {
    "username" : {
      "type" : "string"
    },
    "password" : {
      "type" : "string"
    },
    "publickey" : {
      "type" : "string"
    },
    "accountseq" : {
      "type" : "string"
    }
  },
  "title" : "SftpData"
}
EOF
}

# ---------------------------------------
# Deploy to stage
# --------------------------------------
resource "aws_api_gateway_deployment" "api_deployment" {
  rest_api_id = aws_api_gateway_rest_api.sftp-manage.id
  stage_name = "prod"
  depends_on = [aws_api_gateway_integration.sftp-manage-integration,
                aws_api_gateway_integration.sftp-manage-get-integration,
               aws_lambda_permission.allow_apigateway,
               var.sftp_server_id]  
}
