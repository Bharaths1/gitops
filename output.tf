output "instance_ips" {
  value = ["${aws_instance.myfirstinstance.*.public_ip}"]
}
