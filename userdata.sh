#!/bin/bash
sudo apt update -y
sudo apt install apache2 -y
sudo apt install git -y
git clone https://github.com/gabrielecirulli/2048.git
sudo cp -R 2048/* /var/www/html
sudo systemctl apache2 start
