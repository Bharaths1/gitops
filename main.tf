# Terraform state will be stored in S3
terraform {
  backend "s3" {
    bucket = "terraform-bucket-cloud"
    key    = "terraform-attachemnt.tfstate"
    region = "us-east-1"
    profile = "terraform-master1"
  }
}

# Use AWS Terraform provider
provider "aws" { 
  region = "us-east-1"
}

# Create EC2 instance
resource "aws_instance" "default" {
  ami                    = var.ami
  count                  = var.instance_count
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.default.id]
  source_dest_check      = false
  instance_type          = var.instance_type

  subnet_id              = var.subnetid

  tags = {
    Name = "terraform-default"
  }
}

resource "aws_volume_attachment" "ebs_att" {
  device_name = "/dev/sdh"
  volume_id   = aws_ebs_volume.firstvol.id
  instance_id = aws_instance.default.[count.index]
}

resource "aws_ebs_volume" "firstvol" {
  availability_zone = "us-east-1b"
  size              = 5
}

# Create Security Group for EC2
resource "aws_security_group" "default" {
  vpc_id       = var.vpcid
  name = "terraform-default-sg-cloud"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

}
