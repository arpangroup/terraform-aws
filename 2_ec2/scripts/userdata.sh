#!/bin/bash

set -e  # Exit script on any error
yum update -y
yum install -y httpd

# Disable SSL (HTTPS) configuration
sed -i '/^Redirect.*https:\/\//s/^/#/' /etc/httpd/conf.d/ssl.conf
sed -i '/^NameVirtualHost \*:443/s/^/#/' /etc/httpd/conf.d/ssl.conf
sed -i '/^Listen 443/s/^/#/' /etc/httpd/conf.d/ssl.conf

# Ensure Apache listens only on port 80 (HTTP)
sed -i '/Listen 443/s/^/#/' /etc/httpd/conf/httpd.conf
sed -i '/Listen 80/s/^#//' /etc/httpd/conf/httpd.conf

# Create index.html with "Hello, World!"
echo "Hello, World!" > /var/www/html/index.html

# Start Apache web server
systemctl start httpd
systemctl enable httpd