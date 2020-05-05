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

output "nat_gateway_id" {
 value = "${aws_nat_gateway.DevOps-NatGW.id}"
}