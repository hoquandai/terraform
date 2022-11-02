#!/bin/bash

# install nginx
sudo apt update -y && sudo apt install -y nginx
service nginx start

# update static page
echo '<h1>Nginx Website With Terraform Provisioner</h1>' > /var/www/html/index.html
