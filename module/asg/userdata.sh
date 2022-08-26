#!/bin/bash
sudo yum update -y
sudo yum install httpd -y
sudo yum install git -y
git clone https://github.com/gabrielecirulli/2048.git
sudo cp -R 2048/* /var/www/html
sudo service httpd start
