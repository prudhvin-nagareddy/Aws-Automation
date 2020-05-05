#output "address" {
 # value = aws_elb.web.dns_name
#}

output "nat_instance_id" {
 value = "${aws_instance.DevOps-Nat.id}"
}