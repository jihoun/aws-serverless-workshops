resource "aws_s3_bucket" "bucket" {
  bucket_prefix = "serverless-bucket"
  force_destroy = true

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
  value = "http://${aws_s3_bucket.bucket.website_endpoint}"
}

resource "null_resource" "assets" {
  provisioner "local-exec" {
    command = "aws s3 sync ../WebApplication/1_StaticWebHosting/website/ s3://${aws_s3_bucket.bucket.bucket} --profile ${var.profile}"
  }
}
