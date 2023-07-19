#!/bin/bash

read -p "Masukkan domain Anda (contoh: example.com): " domain
read -p "Masukkan alamat IP server Anda (contoh: 192.168.1.100): " server_ip

# Generate SSL Certificate using Letsencrypt
certbot certonly --standalone --preferred-challenges http -d $domain

# Create Nginx configuration file
cat > /etc/nginx/sites-available/$domain <<EOF
server {
    listen 80;
    server_name $domain;

    location / {
        proxy_pass http://$server_ip;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}

server {
    listen 443 ssl;
    server_name $domain;

    ssl_certificate /etc/letsencrypt/live/$domain/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/$domain/privkey.pem;

    location / {
        proxy_pass http://$server_ip;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}
EOF

# Create a symbolic link to enable the site
ln -s /etc/nginx/sites-available/$domain /etc/nginx/sites-enabled/

# Test Nginx configuration
nginx -t

# Restart Nginx to apply the changes
systemctl restart nginx
