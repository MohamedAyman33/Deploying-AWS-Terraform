variable "ControlIp" {
  type = string
}

variable "Private_subnet_A_id" {
  type = string
}

variable "Public_subnet_A_id" {
  type = string
}

variable "VPC_id" {
  type = string
}

variable "Local_CIDR" {
  type = string
}


variable "PC2_LT_id" {
  type = string
}

variable "Judge_LT_id" {
  type = string
}

variable "WTI_LT_id" {
  type = string
}

variable "SB_LT_id" {
  type = string
}

variable "s3_access_role_name" {
  type = string
  
}
variable "control_role_name" {
  type = string
  
}
variable "aws_s3_bucket_public_access_block" {
  type = string  
}
variable "PC2_IP" {
  type = string
}

variable "efs-judge-mount-target-a" {
  type = string
}

variable "PC2_SG" {
  type = string
}