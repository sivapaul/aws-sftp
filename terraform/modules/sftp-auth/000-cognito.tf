resource "aws_cognito_user_pool" "auth" {
  name                     = "auth"
  alias_attributes         = ["email"]
  auto_verified_attributes = ["email"]

  password_policy {
    minimum_length    = 10
    require_lowercase = false
    require_numbers   = true
    require_symbols   = true
    require_uppercase = true
    temporary_password_validity_days = 7
  }

  schema {
    attribute_data_type      = "String"
    developer_only_attribute = false
    mutable                  = true
    name                     = "email"
    required                 = true

    string_attribute_constraints {
      min_length = 7
      max_length = 50
    }

  }
}

resource "aws_cognito_user_pool_client" "client" {
  name            = "client"
  user_pool_id    = aws_cognito_user_pool.auth.id
  generate_secret = false
}
