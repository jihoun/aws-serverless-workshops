//https://aws.amazon.com/getting-started/hands-on/build-serverless-web-app-lambda-apigateway-s3-dynamodb-cognito/
variable "profile" {
  default = "staging"
}

provider "aws" {
  version = "~> 2.0"
  region  = "ap-southeast-1"
  profile = var.profile
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
