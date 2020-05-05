#! /bin/bash
sudo yum -y update
sudo yum -y install nginx
sudo service nginx start
sudo systemctl enable nginx
echo "<h1>Welcome  To Webserver1</h1>" | sudo tee /var/www/html/index.html