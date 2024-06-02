#Creating ACPC VPC
resource "aws_vpc" "ACPC_VPC" {
  cidr_block = var.CIDR
  tags = {
    Name = "ACPC_VPC"
  }
}

#----------------------------------------------------------------------------------

#Creating public subnets[0,1]
resource "aws_subnet" "Public_Subnets" {
  vpc_id     = aws_vpc.ACPC_VPC.id
  count = length(var.Public_Subnets)
  availability_zone = var.Public_Subnets[count.index].az
  cidr_block = var.Public_Subnets[count.index].cidr
  tags = {
    Name = "Public_Subnet_${var.AZ[count.index]}"
  }
}


#----------------------------------------------------------------------------------------
#Creating private subnets[0,1]
resource "aws_subnet" "Private_Subnets" {
  # enable_resource_name_dns_a_record_on_launch is responsible for making the machine hostname same as resource name 
  enable_resource_name_dns_a_record_on_launch = true
  vpc_id     = aws_vpc.ACPC_VPC.id
  count = length(var.Private_Subnets)
  availability_zone = var.Private_Subnets[count.index].az
  cidr_block = var.Private_Subnets[count.index].cidr
  tags = {
    Name = "Private_Subnet_${var.AZ[count.index]}"
  }
}
#----------------------------------------------------------------------------------------
#Creating IGW
resource "aws_internet_gateway" "ACPC_IGW" {
  vpc_id = aws_vpc.ACPC_VPC.id

  tags = {
    Name = "ACPC_IGW"
  }
}

#----------------------------------------------------------------------------------------
#Creating Elastic IP
resource "aws_eip" "EIP" {
  domain   = "vpc"
}

#----------------------------------------------------------------------------------------
#Creating NAT_GW
resource "aws_nat_gateway" "ACPC_NAT_GW" {
  allocation_id = aws_eip.EIP.id
  subnet_id     = aws_subnet.Public_Subnets[0].id

  tags = {
    Name = "ACPC_NAT_GW"
  }
  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.ACPC_IGW]
}

#----------------------------------------------------------------------------------------
#Create Public-rt
resource "aws_route_table" "Public_rt" {
  vpc_id = aws_vpc.ACPC_VPC.id

  route {
    cidr_block = var.RT_CIDR
    gateway_id = aws_internet_gateway.ACPC_IGW.id
  }


  tags = {
    Name = "Public_rt"
  }
}

#----------------------------------------------------------------------------------------
#Create Private-rt
resource "aws_route_table" "Private_rt" {
  vpc_id = aws_vpc.ACPC_VPC.id

  route {
    cidr_block = var.RT_CIDR
    nat_gateway_id = aws_nat_gateway.ACPC_NAT_GW.id
  }


  tags = {
    Name = "Private_rt"
  }
}

#----------------------------------------------------------------------------------------
#Associate Public-rt with Public Subnets
resource "aws_route_table_association" "Public_rt_ass" {
  count = length(var.Public_Subnets)
  subnet_id      = aws_subnet.Public_Subnets[count.index].id
  route_table_id = aws_route_table.Public_rt.id
}

#----------------------------------------------------------------------------------------

#Associate Private-rt with private Subnets
resource "aws_route_table_association" "Private_rt_ass" {
  count = length(var.Private_Subnets)
  subnet_id      = aws_subnet.Private_Subnets[count.index].id
  route_table_id = aws_route_table.Private_rt.id
}