# JudgeLT User Data 
data "template_file" "Judge_LT_user_data" {
  template = <<-EOF
    #!/bin/bash
    curl -o /tmp/finalize.sh http://10.0.3.33/roles/judge/finalize.sh   
    chmod +x /tmp/finalize.sh
    /tmp/finalize.sh
  EOF
}


# JudgeLT
resource "aws_launch_template" "JudgeLT" {
  name           = "JudgeLT"
  instance_type  = "t2.small"
  key_name       = "acpc-2024-internal"
  image_id       = "ami-0120dc6e0d498cd61"
  user_data      = base64encode(data.template_file.Judge_LT_user_data.rendered)
  

  network_interfaces {
    device_index                = 0
    subnet_id                   = var.Private_Subnet_A_id
    security_groups             = [var.Control_SG_id]
    associate_public_ip_address = false
  }

  placement {
    availability_zone = "eu-central-1a"
  }

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "JudgeLT"
    }
  }
 provisioner "remote-exec" {
    inline = [
      "sudo hostnamectl set-hostname ${self.tags["Name"]}"
    ]
  }
  
}

#------------------------------------------------------------------------------------------------------------------
#Create WTI SG
resource "aws_security_group" "WTI_SG" {
  name        = "WTI_SG"
  description = "WTI_SG"
  vpc_id      = var.VPC_id
  tags = {
    Name = "WTI_LT_SG"
  }
}

#Allow http 
resource "aws_vpc_security_group_ingress_rule" "allow_http" {
  security_group_id = aws_security_group.WTI_SG.id
  cidr_ipv4         = var.Local_CIDR
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

#Allow https 
resource "aws_vpc_security_group_ingress_rule" "allow_https" {
  security_group_id = aws_security_group.WTI_SG.id
  cidr_ipv4         = var.Local_CIDR
  from_port         = 8080
  ip_protocol       = "tcp"
  to_port           = 8080
}

#allow ssh
resource "aws_vpc_security_group_ingress_rule" "allow_ssh" {
  security_group_id = aws_security_group.WTI_SG.id
  cidr_ipv4         = var.Local_CIDR
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

#allow all egress traffic
resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.WTI_SG.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" 
}
# WTI_LT User Data 
data "template_file" "WTI_LT_user_data" {
  template = <<-EOF
    #!/bin/bash
    curl -o /tmp/finalize.sh http://10.0.3.33/roles/wti/finalize.sh
    chmod +x /tmp/finalize.sh
    /tmp/finalize.sh
  EOF
}


# WTI_LT
resource "aws_launch_template" "WTI_LT" {
  name           = "WTI_LT"
  instance_type  = "t3.xlarge"
  key_name       = "acpc-2024-internal"
  image_id       = "ami-056d6bc88ae086ced"
  user_data      = base64encode(data.template_file.WTI_LT_user_data.rendered)

  network_interfaces {
    device_index                = 0
    subnet_id                   = var.Private_Subnet_A_id
    security_groups             = [aws_security_group.WTI_SG.id]
    associate_public_ip_address = false
  }

  placement {
    availability_zone = "eu-central-1a"
  }

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "WTI_LT"
    }
  }
}



#-----------------------------------------------------------------------------------------------------------

#Create pc2 SG
resource "aws_security_group" "PC2_SG" {
  name        = "PC2_SG"
  description = "PC2_SG"
  vpc_id      = var.VPC_id
  tags = {
    Name = "PC2_SG"
  }
}

#Allow http 
resource "aws_vpc_security_group_ingress_rule" "PC2_allow_http" {
  security_group_id = aws_security_group.PC2_SG.id
  cidr_ipv4         = var.Local_CIDR
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

#Allow https 
resource "aws_vpc_security_group_ingress_rule" "PC2_allow_https" {
  security_group_id = aws_security_group.PC2_SG.id
  cidr_ipv4         = var.Local_CIDR
  from_port         = 8080
  ip_protocol       = "tcp"
  to_port           = 8080
}

#Allow PC2 Port
resource "aws_vpc_security_group_ingress_rule" "Allow_PC2_Port" {
  security_group_id = aws_security_group.PC2_SG.id
  cidr_ipv4         = var.Local_CIDR
  from_port         = 50002
  ip_protocol       = "tcp"
  to_port           = 50002
}

#allow ssh
resource "aws_vpc_security_group_ingress_rule" "PC2_allow_ssh" {
  security_group_id = aws_security_group.PC2_SG.id
  cidr_ipv4         = var.Local_CIDR
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

#allow all egress traffic
resource "aws_vpc_security_group_egress_rule" "PC2_allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.PC2_SG.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" 
}
# PC2_LT User Data 
data "template_file" "PC2_LT_user_data" {
  template = <<-EOF
    #!/bin/bash
    curl -o /tmp/finalize.sh http://10.0.3.33/roles/pc2/finalize.sh
    chmod +x /tmp/finalize.sh
    /tmp/finalize.sh
  EOF
}


# PC2_LT
resource "aws_launch_template" "PC2_LT" {
  name           = "PC2_LT"
  instance_type  = "c5.xlarge"
  key_name       = "acpc-2024-internal"
  image_id       = "ami-0b2f980184acf8237"
  user_data      = base64encode(data.template_file.PC2_LT_user_data.rendered)

  network_interfaces {
    device_index                = 0
    subnet_id                   = var.Private_Subnet_A_id
    security_groups             = [aws_security_group.PC2_SG.id]
    associate_public_ip_address = false
  }

  placement {
    availability_zone = "eu-central-1a"
  }

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "PC2_LT"
    }
  }
}


#----------------------------------------------------------------------------------------------------------------------------
#Create SB_SG
resource "aws_security_group" "SB_SG" {
  name        = "SB_SG"
  description = "SB_SG"
  vpc_id      = var.VPC_id
  tags = {
    Name = "SB_SG"
  }
}

#Allow https 
resource "aws_vpc_security_group_ingress_rule" "SB_SG_allow_https" {
  security_group_id = aws_security_group.SB_SG.id
  cidr_ipv4         = var.Local_CIDR
  from_port         = 8080
  ip_protocol       = "tcp"
  to_port           = 8080
}

#allow ssh
resource "aws_vpc_security_group_ingress_rule" "SB_SG_allow_ssh" {
  security_group_id = aws_security_group.SB_SG.id
  cidr_ipv4         = var.Local_CIDR
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

#allow all egress traffic
resource "aws_vpc_security_group_egress_rule" "SB_SG_allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.SB_SG.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" 
}
# SB_SG User Data 
data "template_file" "SB_LT_user_data" {
  template = <<-EOF
    #!/bin/bash
    curl -o /tmp/finalize.sh http://10.0.3.33/roles/sb/finalize.sh
    chmod +x /tmp/finalize.sh
    /tmp/finalize.sh
  EOF
}


# SB_SG
resource "aws_launch_template" "SB_LT" {
  name           = "SB_LT"
  instance_type  = "c5.xlarge"
  key_name       = "acpc-2024-internal"
  image_id       = "ami-0f3975be2ba26979a"
  user_data      = base64encode(data.template_file.WTI_LT_user_data.rendered)

  network_interfaces {
    device_index                = 0
    subnet_id                   = var.Private_Subnet_A_id
    security_groups             = [aws_security_group.SB_SG.id]
    associate_public_ip_address = false
  }

  placement {
    availability_zone = "eu-central-1a"
  }

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "SB_LT"
    }
  }
  iam_instance_profile {
      name= var.s3_access_role_name

  }
}
