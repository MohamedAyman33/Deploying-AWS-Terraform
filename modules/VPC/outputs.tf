output "VPC_id" {
  value = aws_vpc.ACPC_VPC.id
}


output "Private_Subnets_id" {
  value =  aws_subnet.Private_Subnets[*].id
}


output "Public_subnets_id" {
  value = aws_subnet.Public_Subnets[*].id
}