output "PC2_LT_id" {
  value = aws_launch_template.PC2_LT.id
}

output "Judge_LT_id" {
  value = aws_launch_template.JudgeLT.id
}

output "WTI_LT_id" {
  value = aws_launch_template.WTI_LT.id
}

output "SB_LT_id" {
  value = aws_launch_template.SB_LT.id
}
output "pc2_sg" {
  value = aws_security_group.PC2_SG.id
}