variable "subnet_id" {
  description = "The ID of the private subnet where the EC2 instance will be launched"
  type        = string
}

variable "iam_instance_profile" {
  description = "The IAM instance profile to associate with the EC2 instance"
  type        = string
}