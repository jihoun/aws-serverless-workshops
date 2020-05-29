
resource "aws_api_gateway_method" "CORS" {
  rest_api_id   = var.api_id
  resource_id   = var.resource_id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "CORS" {
  rest_api_id = var.api_id
  resource_id = var.resource_id
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
  rest_api_id = var.api_id
  resource_id = var.resource_id
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
  rest_api_id     = var.api_id
  http_method     = aws_api_gateway_method.CORS.http_method
  resource_id     = var.resource_id
  status_code     = 200
  response_models = { "application/json" = "Empty" }
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = false
    "method.response.header.Access-Control-Allow-Methods" = false
    "method.response.header.Access-Control-Allow-Origin"  = false
  }
}
