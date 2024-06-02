variable "S3_id" {
  type = string
}

variable "WTI_SourceCode" {
  type = string
}

variable "aws_s3_bucket_public_access_block" {
  type = string
}

variable "vpc-id" {
  type = string
}

variable "private-subnets" {
  type = list(string)
}

variable "public-subnets" {
  type = list(string)
}

variable "pc2_ec2" {
  type = string
}