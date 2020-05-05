# Specify the provider and access details
provider "aws" {
  region = var.aws_region
  access_key = var.access_key
  secret_key = var.secret_key
}

  # TF-UPGRADE-TODO: In Terraform v0.10 and earlier, it was sometimes necessary to force an interpolation expression to be interpreted as a list by wrapping it in an extra set of list brackets. That form was supported for compatibility in v0.11, but is no longer supported in Terraform v0.12.
  # If the expression in the following list itself returns a list, remove the brackets to avoid interpretation as a list of lists. If the expression returns a single list item then leave it as-is and remove this TODO comment.

resource "aws_instance" "DevOps-WebServer1" {
  instance_type = "t2.micro"

  # Lookup the correct AMI based on the region
  # we specified
  ami = var.aws_amis[var.aws_region]
  tags = {
    Name = "DevOps-WebServer1"
  }
  # The name of our SSH keypair we created above.
  key_name = var.key_name

  # Our Security group to allow HTTP and SSH access
  vpc_security_group_ids = [aws_security_group.DevOps-EC2-SG.id]

  # We're going to launch into the PUBLIC subnet 
  subnet_id = "${aws_subnet.public-subnet.0.id}"

  # Install Nginx while launching the Instance with help of 
  # User-data
  user_data = "${file("install-nginx.sh")}"

}

resource "aws_instance" "DevOps-WebServer2" {
  instance_type = "t2.micro"

  # Lookup the correct AMI based on the region
  # we specified
  ami = var.aws_amis[var.aws_region]
  tags = {
    Name = "DevOps-WebServer2"
  }
  # The name of our SSH keypair we created above.
  key_name = var.key_name

  # Our Security group to allow HTTP and SSH access
  vpc_security_group_ids = [aws_security_group.DevOps-EC2-SG.id]

  # We're going to launch into the PUBLIC subnet
  subnet_id = "${aws_subnet.public-subnet.1.id}"

  # Install Apache2 while launching the Instance with help of User-data
  user_data = "${file("install-apache.sh")}"

}
  
resource "aws_instance" "DevOps-AppServer1" {
  instance_type = "t2.micro"

  # Lookup the correct AMI based on the region
  # we specified
  ami = var.aws_amis[var.aws_region]
  tags = {
    Name = "DevOps-AppServer1"
  }
  # The name of our SSH keypair we created above.
  key_name = var.key_name

  # Our Security group to allow HTTP and SSH access
  vpc_security_group_ids = [aws_security_group.DevOps-EC2-SG.id]

  # We're going to launch into the PRIVATE subnet of Availability Zone-A. 
  subnet_id = "${aws_subnet.private-subnet.0.id}"

}

resource "aws_instance" "DevOps-AppServer2" {
  instance_type = "t2.micro"

  # Lookup the correct AMI based on the region
  # we specified
  ami = var.aws_amis[var.aws_region]
  tags = {
    Name = "DevOps-AppServer2"
  }
  # The name of our SSH keypair we created above.
  key_name = var.key_name

  # Our Security group to allow HTTP and SSH access
  vpc_security_group_ids = [aws_security_group.DevOps-EC2-SG.id]

  # We're going to launch into the PRIVATE subnet of Availability Zone-B
  subnet_id = "${aws_subnet.private-subnet.1.id}"

}
