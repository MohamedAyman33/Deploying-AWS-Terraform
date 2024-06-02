output "aws_s3_bucket_public_access_block" {
  value = aws_s3_bucket_public_access_block.example.id
}


output "WTI_SourceCode" {
  value = aws_s3_object.WTI_SourceCode.key
}

output "S3_id" {
  value = aws_s3_bucket.ACPC-S3-acpc-global.id
}





