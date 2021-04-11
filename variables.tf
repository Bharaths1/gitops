variable "instance_count" {
  default = 1
}

variable "key_name" {
  description = "Private key name to use with instance"
  default     = "JenkinsTerraform"
}

variable "instance_type" {
  description = "AWS instance type"
  default     = "t2.micro"
}

variable "ami" {
  description = "Base AMI to launch the instances in EC2 in develop"

  # Bitnami NGINX AMI
  default = "ami-02eac2c0129f6376b"
}

variable "vpcid" {
    default = "vpc-073d5d425d86425d4"
}
variable "subnetid" {
    default = "subnet-07ef0ec79444557b8"
}

