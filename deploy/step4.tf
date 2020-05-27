resource "aws_api_gateway_rest_api" "WildRydes" {
  name        = "WildRydes"
  description = "This is my API for wildrydes hands-on"
}

resource "aws_api_gateway_authorizer" "auth" {
  name          = "cognitoauth"
  rest_api_id   = aws_api_gateway_rest_api.WildRydes.id
  type          = "COGNITO_USER_POOLS"
  provider_arns = [aws_cognito_user_pool.pool.arn]
}

resource "aws_api_gateway_resource" "ride" {
  rest_api_id = aws_api_gateway_rest_api.WildRydes.id
  parent_id   = aws_api_gateway_rest_api.WildRydes.root_resource_id
  path_part   = "ride"
}

resource "aws_api_gateway_method" "CORS" {
  rest_api_id   = aws_api_gateway_rest_api.WildRydes.id
  resource_id   = aws_api_gateway_resource.ride.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "CORS" {
  rest_api_id = aws_api_gateway_rest_api.WildRydes.id
  resource_id = aws_api_gateway_resource.ride.id
  http_method = aws_api_gateway_method.CORS.http_method
  type        = "MOCK"

  request_templates = {
    "application/json" = <<EOF
{
  "statusCode": 200
}
EOF
  }
}

resource "aws_api_gateway_integration_response" "CORS" {
  rest_api_id = aws_api_gateway_rest_api.WildRydes.id
  resource_id = aws_api_gateway_resource.ride.id
  status_code = 200
  http_method = aws_api_gateway_method.CORS.http_method

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,Authorization,X-Amz-Date,X-Api-Key,X-Amz-Security-Token'"
    "method.response.header.Access-Control-Allow-Methods" = "'DELETE,GET,HEAD,OPTIONS,PATCH,POST,PUT'"
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }
  response_templates = { "application/json" = "" }
  depends_on         = [aws_api_gateway_integration.CORS]
}

resource "aws_api_gateway_method_response" "CORS" {
  rest_api_id     = aws_api_gateway_rest_api.WildRydes.id
  http_method     = aws_api_gateway_method.CORS.http_method
  resource_id     = aws_api_gateway_resource.ride.id
  status_code     = 200
  response_models = { "application/json" = "Empty" }
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = false
    "method.response.header.Access-Control-Allow-Methods" = false
    "method.response.header.Access-Control-Allow-Origin"  = false
  }
}

resource "aws_api_gateway_method" "POST" {
  rest_api_id   = aws_api_gateway_rest_api.WildRydes.id
  resource_id   = aws_api_gateway_resource.ride.id
  http_method   = "POST"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.auth.id
}

resource "aws_api_gateway_integration" "POST" {
  rest_api_id             = aws_api_gateway_rest_api.WildRydes.id
  http_method             = aws_api_gateway_method.POST.http_method
  resource_id             = aws_api_gateway_resource.ride.id
  type                    = "AWS_PROXY"
  cache_key_parameters    = []
  content_handling        = "CONVERT_TO_TEXT"
  integration_http_method = "POST"
  request_parameters      = {}
  request_templates       = {}
  uri                     = "arn:aws:apigateway:${data.aws_region.current.name}:lambda:path/2015-03-31/functions/${aws_lambda_function.lambda.arn}/invocations"
}

resource "aws_api_gateway_method_response" "POST" {
  resource_id     = aws_api_gateway_resource.ride.id
  status_code     = 200
  rest_api_id     = aws_api_gateway_rest_api.WildRydes.id
  http_method     = aws_api_gateway_method.POST.http_method
  response_models = { "application/json" = "Empty" }
}

resource "aws_api_gateway_deployment" "prod" {
  depends_on = [aws_api_gateway_integration.POST]

  rest_api_id = aws_api_gateway_rest_api.WildRydes.id
  stage_name  = "prod"

  lifecycle {
    create_before_destroy = true
  }
}

//once all resources are created, upload the proper config file
resource "aws_s3_bucket_object" "config" {
  key    = "js/config.js"
  bucket = aws_s3_bucket.bucket.id

  content    = <<JS
window._config = {
    cognito: {
        userPoolId: '${aws_cognito_user_pool.pool.id}',
        userPoolClientId: '${aws_cognito_user_pool_client.client.id}', 
        region: '${data.aws_region.current.name}'
    },
    api: {
        invokeUrl: '${aws_api_gateway_deployment.prod.invoke_url}'
    }
};
JS
  depends_on = [null_resource.assets]
}
