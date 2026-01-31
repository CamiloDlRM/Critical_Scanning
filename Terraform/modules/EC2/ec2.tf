resource "aws_network_interface" "eni_dev" {
  subnet_id   = var.subnet_id
  private_ips = ["10.0.2.10"]

  tags = {
    Name = "dev_network_interface"
  }
}

resource "aws_instance" "ec2_dev_instance" {
  ami           = "ami-0f5fcdfbd140e4ab7" 
  instance_type = "t2.micro"
  user_data    = file("${path.module}/docker_base_installation.sh")
  iam_instance_profile = var.iam_instance_profile
  primary_network_interface {
    network_interface_id = aws_network_interface.eni_dev.id
  }

  credit_specification {
    cpu_credits = "unlimited"
  }

   tags = {
    Name = "ec2_dev_instance"
  }


}

