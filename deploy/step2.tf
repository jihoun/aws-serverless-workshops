resource "aws_cognito_user_pool" "pool" {
  name = "serverless-hands-on"

  password_policy {
    minimum_length                   = 6
    require_lowercase                = false
    require_numbers                  = false
    require_symbols                  = false
    require_uppercase                = false
    temporary_password_validity_days = 7
  }
}

resource "aws_cognito_user_pool_client" "client" {
  name = "WildRydesWebApp"

  user_pool_id = aws_cognito_user_pool.pool.id
}

# output "userPoolId" {
#   value = aws_cognito_user_pool.pool.id
# }

# output "userPoolClientId" {
#   value = aws_cognito_user_pool_client.client.id
# }
