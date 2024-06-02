#Create EFS SecurityGroup
resource "aws_security_group" "efs_sg" {
  name        = "efs_sg"
  description = "efs_sg"
  vpc_id      = var.vpc-id
  tags = {
    Name = "efs_sg"
  }
}

#Allow mount port
resource "aws_vpc_security_group_ingress_rule" "efs_sg_allow_mount" {
  security_group_id = aws_security_group.efs_sg.id
  cidr_ipv4         = "10.0.0.0/8"
  from_port         = 2049
  ip_protocol       = "tcp"
  to_port           = 2049
}


#allow all egress traffic
resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.efs_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" 
}



#Create EFS storage
resource "aws_efs_file_system" "judge_efs" {
  creation_token = "judge_efs"

  tags = {
    Name = "judge_efs"
  }
}

#Add Mount Point to EFS Storage in private a subnet
resource "aws_efs_mount_target" "judge_efs_mount_target-a" {
  file_system_id = aws_efs_file_system.judge_efs.id
  subnet_id      = var.Private_Subnets_id[0]
  security_groups = [aws_security_group.efs_sg.id]
  ip_address = "10.0.3.20"
}


#Add Mount Point to EFS Storage in provate b subnet
resource "aws_efs_mount_target" "judge_efs_mount_target-b" {
  file_system_id = aws_efs_file_system.judge_efs.id
  subnet_id      = var.Private_Subnets_id[1]
  security_groups = [aws_security_group.efs_sg.id]
  ip_address = "10.0.4.20"
}