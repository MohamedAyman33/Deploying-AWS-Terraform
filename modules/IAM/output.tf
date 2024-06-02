
output "control_Profile" {
  value = aws_iam_instance_profile.ec2_role_policy_profile.name
}
output "s3_access_Profile" {
  value = aws_iam_instance_profile.s3_instance_profile.name
}