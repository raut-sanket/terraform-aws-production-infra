output "ec2_role_arn" {
  value = aws_iam_role.ec2.arn
}

output "ec2_instance_profile_arn" {
  value = aws_iam_instance_profile.ec2.arn
}

output "cicd_role_arn" {
  value = aws_iam_role.cicd.arn
}
