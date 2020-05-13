# Nat-Instance
# Create a Nat-Instance
resource "aws_instance" "DevOps-Nat" {
  instance_type = "t2.micro"
  ami = "${var.aws_nat_amis[var.aws_region]}"
  subnet_id = "${aws_subnet.public-subnet.0.id}"
  vpc_security_group_ids = [aws_security_group.DevOps-EC2-SG.id]
  associate_public_ip_address = true
  source_dest_check = false
  key_name = var.key_name
  tags = {
    Name = "DevOps-Nat"
  }
}

resource "aws_eip" "nat" {
   instance = "${aws_instance.DevOps-Nat.id}"
   vpc = true
}