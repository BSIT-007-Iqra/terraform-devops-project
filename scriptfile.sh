#!/bin/bash
sudo apt update -y
sudo apt install -y nginx
sudo systemctl start nginx
sudo systemctl enable nginx
echo " <center> <h1>NGINX Installation Complete</h1><hr/>
<h2>NGINX is running on port 80</h2><hr/>
<h3>Welcome! NGINX Screen</h3></center>" | tee /var/www/html/index.html