# Creating the S3 bucket
resource "aws_s3_bucket" "ACPC-S3-acpc-global" {
  bucket = var.S3_Name
  # force_destroy = true
  tags = {
    Name = var.S3_Name
  }
}


#push WTI Source Code To S3
resource "aws_s3_object" "WTI_SourceCode" {
  key                    = "wti.zip"
  bucket                 = aws_s3_bucket.ACPC-S3-acpc-global.id
  source                 = "wti.zip"
}


# #push index.html To S3
# resource "aws_s3_object" "index-html" {
#   key                    = "index.html"
#   bucket                 = aws_s3_bucket.ACPC-S3-acpc-global.id
#   source                 = "index.html"
# }



#for static website hosting
resource "aws_s3_bucket_website_configuration" "s3-static-hosting" {
  bucket = aws_s3_bucket.ACPC-S3-acpc-global.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

# Bucket policy to allow public read access
resource "aws_s3_bucket_policy" "ACPC-S3-BucketPolicy" {
  bucket = aws_s3_bucket.ACPC-S3-acpc-global.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = "*"
        Action = [
          "s3:GetObject"
        ]
        Resource = "${aws_s3_bucket.ACPC-S3-acpc-global.arn}/*"
      }
    ]
  })
}

#aws_s3_bucket_public_access_block
resource "aws_s3_bucket_public_access_block" "example" {
  bucket = aws_s3_bucket.ACPC-S3-acpc-global.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}
