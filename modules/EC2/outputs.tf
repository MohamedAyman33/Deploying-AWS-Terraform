output "Control_SG_id" {
  value = aws_security_group.Control_SG.id
}

output "PC2_ec2" {
  value = aws_instance.PC2.id
}