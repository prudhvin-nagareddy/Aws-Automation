# Specify the provider and access details
provider "aws" {
  region = var.aws_region
  access_key = var.access_key
  secret_key = var.secret_key
}

  # In Terraform v0.10 and earlier, it was sometimes necessary to force an interpolation expression to be interpreted as a list by wrapping it in an extra set of list brackets. That form was supported for compatibility in v0.11, but is no longer supported in Terraform v0.12.
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
  subnet_id = aws_subnet.public-subnet.0.id

  # Install Nginx while launching the Instance with help of 
  # User-data
  user_data = "${file("install-nginx.sh")}"
#  depends_on = aws_subnet.public-subnet
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
  subnet_id = aws_subnet.public-subnet.1.id

  # Install Apache2 while launching the Instance with help of User-data
  user_data = "${file("install-apache.sh")}"
#  depends_on = aws_subnet.public.subnet
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
  subnet_id = aws_subnet.private-subnet.0.id
#  depends_on = aws-subnet.private-subnet
  user_data = <<HEREDOC
    #!/bin/bash
    sleep 180
    yum update -y
    yum install -y mysql55-server
    service mysqld start
    /usr/bin/mysqladmin -u root password 'secret'
    mysql -u root -psecret -e "create user 'root'@'%' identified by 'secret';" mysql
    mysql -u root -psecret -e 'CREATE TABLE Employees (ID int(11) NOT NULL AUTO_INCREMENT, NAME varchar(45) DEFAULT NULL, ADDRESS varchar(255) DEFAULT NULL, PRIMARY KEY (ID));' test
    mysql -u root -psecret -e "INSERT INTO Employees (NAME, ADDRESS) values ('JOHN', 'LONDON UK') ;" test
  HEREDOC
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
  subnet_id = aws_subnet.private-subnet.1.id
#  depends_on = aws_subnet.private-subnet
}

resource "aws_elb" "DevOps-ELB" {
  name = "DevOps-ELB"
  subnets         = "${aws_subnet.public-subnet.*.id}"
  security_groups = ["${aws_security_group.DevOps-ELB-SG.id}"]
  tags = {
    Name = "DevOps-ELB"
  }

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

  cross_zone_load_balancing   = true
  idle_timeout                = 400
  connection_draining         = true
  connection_draining_timeout = 400

}

resource "aws_elb_attachment" "DevOps-ELB-Attachment" {
  count = 2
  elb = "${aws_elb.DevOps-ELB.id}"
  instance = "${element(list("${aws_instance.DevOps-WebServer1.id}", "${aws_instance.DevOps-WebServer2.id}"), count.index)}"
#  depends_on = ["${aws_instance.DevOps-WebServer*}"]
}
