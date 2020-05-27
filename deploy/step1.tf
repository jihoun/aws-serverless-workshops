//https://aws.amazon.com/getting-started/hands-on/build-serverless-web-app-lambda-apigateway-s3-dynamodb-cognito/module-1/
variable "profile" {
  default = "staging"
}

provider "aws" {
  version = "~> 2.0"
  region  = "us-east-1"
  profile = var.profile
}

resource "aws_s3_bucket" "bucket" {
  bucket_prefix = "serverless-bucket"

  website {
    index_document = "index.html"
  }
}

resource "aws_s3_bucket_policy" "bucket_policy" {
  bucket = aws_s3_bucket.bucket.id

  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow", 
            "Principal": "*", 
            "Action": "s3:GetObject", 
            "Resource": "arn:aws:s3:::${aws_s3_bucket.bucket.bucket}/*" 
        } 
    ] 
}
POLICY
}

output "frontend" {
  value = aws_s3_bucket.bucket.website_endpoint
}

resource "null_resource" "create-endpoint" {
  provisioner "local-exec" {
    command = "aws s3 sync ../WebApplication/1_StaticWebHosting/website/ s3://${aws_s3_bucket.bucket.bucket} --profile ${var.profile}"
  }
}
