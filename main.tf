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
resource "aws_instance" "myfirstinstance" {
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
  instance_id = aws_instance.myfirstinstance[0].id
}
resource "aws_ebs_volume" "firstvol" {
  availability_zone = "us-east-1a"
  size              = 10
}

resource "aws_elb" "myfirstinstanceelb" {
  name               = "myfirstinstanceelb-terraform"
  availability_zones = ["us-east-1a", "us-east-1b", "us-east-1c"]
    subnets         = ["subnet-07ef0ec79444557b8", "subnet-060772055a466b594"]
  internal        = true

  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }


  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:80/"
    interval            = 30
  }

  instances                   = [aws_instance.myfirstinstance[0].id]
  cross_zone_load_balancing   = true
  idle_timeout                = 400
  connection_draining         = true
  connection_draining_timeout = 400

  tags = {
    Name = "myfirstinstanceelb-terraform"
  }
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
