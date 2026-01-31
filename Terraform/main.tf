module iam {
  source = "./modules/IAM"
}

module networking {
  source = "./modules/NETWORKING"
}

module ec2 {
  source = "./modules/EC2"

  subnet_id = module.networking.private_subnet_id
  iam_instance_profile = module.iam.iam_instance_profile
}
