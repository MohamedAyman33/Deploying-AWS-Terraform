#Create Control SG
resource "aws_security_group" "Control_SG" {
  name        = "Control_SG"
  description = "Control_SG"
  vpc_id      = var.VPC_id
  tags = {
    Name = "Control_SG"
  }
}

#Allow http 
resource "aws_vpc_security_group_ingress_rule" "allow_http" {
  security_group_id = aws_security_group.Control_SG.id
  cidr_ipv4         = var.Local_CIDR
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

#allow ssh
resource "aws_vpc_security_group_ingress_rule" "allow_ssh" {
  security_group_id = aws_security_group.Control_SG.id
  cidr_ipv4         = var.Local_CIDR
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

#allow all egress traffic
resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.Control_SG.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" 
}

#Creating Control EC2 machine
resource "aws_instance" "Control" {
  ami           = "ami-0112b50a504c1cd53" 
  instance_type = "t2.micro"
  iam_instance_profile = var.control_role_name

  private_ip = var.ControlIp
  subnet_id     = var.Private_subnet_A_id
  key_name = "acpc-2024-internal"
  vpc_security_group_ids = [aws_security_group.Control_SG.id]
  
  tags = {
    Name = "control"
    "aws:ec2:hostname"                = "Name"
  }
   user_data              = <<-EOF
    #!/bin/bash
    sudo apt update -y 
    sudo apt install apache2 -y 
    sudo systemctl start apache2
    sudo systemctl enable apache2
  EOF 
}


#---------------------------------------------------------------------------------------------------------------------
#Create VPN_SG
resource "aws_security_group" "VPN_SG" {
  name        = "VPN_SG"
  description = "VPN_SG"
  vpc_id      = var.VPC_id
  tags = {
    Name = "VPN_SG"
  }
}

#Allow VPN_Port
resource "aws_vpc_security_group_ingress_rule" "VPN_SG_allow_VPN_Port" {
  security_group_id = aws_security_group.VPN_SG.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 1194
  ip_protocol       = "tcp"
  to_port           = 1194
}

#allow ssh
resource "aws_vpc_security_group_ingress_rule" "VPN_SG_allow_ssh" {
  security_group_id = aws_security_group.VPN_SG.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

#allow all egress traffic
resource "aws_vpc_security_group_egress_rule" "VPN_SG_allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.VPN_SG.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" 
}

# #Create EIP for VPN Ec2
resource "aws_eip" "VPN_EIP" {
  instance = aws_instance.VPN_EC2.id
  domain   = "vpc"
}

# #Creating VPN EC2 machine
resource "aws_instance" "VPN_EC2" {
  ami           = "ami-0c6075344dcd15122" 
  instance_type = "t2.micro"
  subnet_id     = var.Public_subnet_A_id
  key_name = "acpc-2024-external"
  vpc_security_group_ids = [aws_security_group.VPN_SG.id]
  tags = {
    Name = "vpn"
    "aws:ec2:hostname"                = "Name"
  }
}

#------------------------------------------------------------------------------------------------------------------------------------------
resource "aws_instance" "PC2" {
  # Reference the launch template
  
  private_ip = "10.0.3.111"
  ami = "ami-0b2f980184acf8237"
  instance_type  = "c5.xlarge"
  key_name       = "acpc-2024-internal"
  vpc_security_group_ids = [var.PC2_SG]
  subnet_id = var.Private_subnet_A_id
  # increase volume size to prevent system issues
  root_block_device {
    volume_size = 50
  }
  user_data              = <<-EOF
   #!/bin/bash
    curl -o /tmp/finalize.sh http://10.0.3.33/roles/pc2/finalize.sh
    chmod +x /tmp/finalize.sh
    /tmp/finalize.sh
  EOF 
   tags = {
    Name = "pc2"
    "aws:ec2:hostname"                = "Name"
  }
  depends_on = [aws_instance.Control]
}
#------------------------------------------------------------------------------------------------------------------------------------------
resource "aws_instance" "SB" {
  # Reference the launch template
  launch_template {
    id      = var.SB_LT_id
    version = "$Latest"
  }
   tags = {
    Name = "sb"
    "aws:ec2:hostname"                = "Name"
  }
  iam_instance_profile = var.s3_access_role_name
  depends_on = [aws_instance.Control , var.aws_s3_bucket_public_access_block,aws_instance.PC2]

}
#------------------------------------------------------------------------------------------------------------------------------------------
#Comment bec it runs as BeanStalk
 #resource "aws_instance" "WTI" {
#   # Reference the launch template
#   launch_template {
#     id      = var.WTI_LT_id
#     version = "$Latest"
#   }
#    tags = {
#     Name = "wti"
#     "aws:ec2:hostname"                = "Name"
#   }
#   depends_on = [aws_instance.Control,aws_instance.PC2]

# }
#-------------------------------------------------------------------------------------------------------------------------------------------
resource "aws_instance" "Judges" {
  # Define the number of instances
  for_each = toset(["1", "2"]) # Adjust the set according to the desired number of instances
  root_block_device {
    volume_size = 25
  }
  # Reference the launch template
  launch_template {
    id      = var.Judge_LT_id
    version = "$Latest"
  }

  tags = {
    Name = "judge${each.key}"
    "aws:ec2:hostname"                = "Name"
  }

  depends_on = [aws_instance.Control,var.efs-judge-mount-target-a,aws_instance.PC2]
}