output "iam_instance_profile" {
    description = "The IAM instance profile for EC2 instances"
    value       = aws_iam_instance_profile.ec2_profile.name
}