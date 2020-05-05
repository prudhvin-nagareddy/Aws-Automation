output "address" {
  value = aws_elb.DevOps-ELB.dns_name
}

output "NatInstance_ip" {
	value = "${aws_instance.DevOps-Nat.public_ip}"
}

output "nat_instance_id" {
 value = "${aws_instance.DevOps-Nat.id}"
}

output "Webserver1_ip" {
  value = "${aws_instance.DevOps-WebServer1.public_ip}"
}

output "Webserver2_ip" {
  value = "${aws_instance.DevOps-WebServer2.public_ip}"
}

output "Appserver1_ip" {
  value = "${aws_instance.DevOps-AppServer1.private_ip}"
}

output "Appserver2_ip" {
  value = "${aws_instance.DevOps-AppServer2.private_ip}"
}

