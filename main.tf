module "VPC" {
  source = "./modules/VPC"
  CIDR = var.My-CIDR
  AZ = var.My_AZ
  Public_Subnets = var.My_Public_Subnet
  Private_Subnets = var.My_Private_Subnet
  RT_CIDR = var.My_RT_CIDR
}

module "EC2" {
  source = "./modules/EC2"
  ControlIp = var.My_ControlIp
  VPC_id = module.VPC.VPC_id
  Local_CIDR = var.My_Local_CIDR
  Private_subnet_A_id = module.VPC.Private_Subnets_id[0]
  Public_subnet_A_id = module.VPC.Public_subnets_id[0]
  WTI_LT_id = module.LaunchTemplate.WTI_LT_id
  PC2_LT_id = module.LaunchTemplate.PC2_LT_id
  Judge_LT_id = module.LaunchTemplate.Judge_LT_id
  SB_LT_id = module.LaunchTemplate.SB_LT_id
  control_role_name = module.IAM.control_Profile
  s3_access_role_name = module.IAM.s3_access_Profile
  aws_s3_bucket_public_access_block = module.S3_Bucket.aws_s3_bucket_public_access_block
  PC2_IP = var.MY_PC2_IP
  efs-judge-mount-target-a = module.EFS.efs-judge-mount-target
  PC2_SG = module.LaunchTemplate.pc2_sg
}


module "LaunchTemplate" {
  source = "./modules/LaunchTemplate"
  VPC_id = module.VPC.VPC_id
  Control_SG_id = module.EC2.Control_SG_id
  Local_CIDR = var.My_Local_CIDR
  Private_Subnet_A_id = module.VPC.Private_Subnets_id[0]
  s3_access_role_name = module.IAM.s3_access_Profile
}

module "S3_Bucket" {
  source = "./modules/S3_Bucket"
  S3_Name = var.My_s3_Name
}
module "IAM" {
  source = "./modules/IAM"
}

module "Beanstalk" {
  source = "./modules/Beanstalk"
  WTI_SourceCode = module.S3_Bucket.WTI_SourceCode
  S3_id = module.S3_Bucket.S3_id
  aws_s3_bucket_public_access_block = module.S3_Bucket.aws_s3_bucket_public_access_block
  private-subnets = module.VPC.Private_Subnets_id
  vpc-id = module.VPC.VPC_id
  pc2_ec2 = module.EC2.PC2_ec2
  public-subnets = module.VPC.Public_subnets_id
}


module "EFS" {
  source = "./modules/EFS"
  Private_Subnets_id = module.VPC.Private_Subnets_id
  vpc-id = module.VPC.VPC_id
}