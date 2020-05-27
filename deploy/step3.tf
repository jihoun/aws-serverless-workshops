resource "aws_dynamodb_table" "db" {
  name = "Rides"

  hash_key     = "RideId"
  billing_mode = "PAY_PER_REQUEST"

  attribute {
    name = "RideId"
    type = "S"
  }
}

resource "aws_iam_role" "lambda_role" {
  name_prefix        = "lambda_role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "lambda_role" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  role       = aws_iam_role.lambda_role.name
}

resource "aws_iam_role_policy" "lambda_role" {
  name_prefix = "DynamoDBWriteAccess"
  role        = aws_iam_role.lambda_role.name
  policy      = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "dynamodb:PutItem",
      "Resource": "${aws_dynamodb_table.db.arn}"
    }
  ]
}
POLICY
}

resource "aws_lambda_function" "lambda" {
  function_name = "RequestUnicorn"
  runtime       = "nodejs10.x"
  role          = aws_iam_role.lambda_role.arn
  handler       = "requestUnicorn.handler"
  filename      = data.archive_file.lambda.output_path
}

data "archive_file" "lambda" {
  type        = "zip"
  source_file = "${path.module}/../WebApplication/3_ServerlessBackend/requestUnicorn.js"
  output_path = "${path.module}/../build/requestUnicorn.zip"
}
