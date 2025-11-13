#!/bin/bash
# User data script for web server setup

set -e

# Update system packages
apt-get update
apt-get upgrade -y

# Install necessary packages
apt-get install -y \
    nginx \
    ufw \
    fail2ban \
    unattended-upgrades \
    apt-listchanges

# Configure automatic security updates
dpkg-reconfigure -plow unattended-upgrades

# Configure firewall (UFW)
ufw default deny incoming
ufw default allow outgoing
ufw allow 80/tcp
ufw allow 443/tcp
ufw allow 22/tcp
echo "y" | ufw enable

# Configure fail2ban for SSH protection
systemctl enable fail2ban
systemctl start fail2ban

# Create web application directory
mkdir -p /var/www/html

# Deploy simple web application
cat > /var/www/html/index.html << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Secure Web Server</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            max-width: 800px;
            margin: 50px auto;
            padding: 20px;
            background-color: #f5f5f5;
        }
        .container {
            background-color: white;
            padding: 30px;
            border-radius: 8px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }
        h1 {
            color: #333;
        }
        .status {
            color: #28a745;
            font-weight: bold;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>Secure Web Server Deployment</h1>
        <p class="status">✓ Server is running securely</p>
        <h2>Security Features Implemented:</h2>
        <ul>
            <li>VPC with public and private subnets</li>
            <li>Security groups with minimal required access</li>
            <li>IAM roles following principle of least privilege</li>
            <li>Encrypted EBS volumes</li>
            <li>IMDSv2 for instance metadata</li>
            <li>Firewall (UFW) configured</li>
            <li>Fail2Ban for intrusion prevention</li>
            <li>Automatic security updates enabled</li>
        </ul>
    </div>
</body>
</html>
EOF

# Configure Nginx
cat > /etc/nginx/sites-available/default << 'EOF'
server {
    listen 80 default_server;
    listen [::]:80 default_server;

    root /var/www/html;
    index index.html;

    server_name _;

    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header Referrer-Policy "no-referrer-when-downgrade" always;

    # Disable server tokens
    server_tokens off;

    location / {
        try_files $uri $uri/ =404;
    }

    # Deny access to hidden files
    location ~ /\. {
        deny all;
    }
}
EOF

# Test and reload Nginx
nginx -t
systemctl restart nginx
systemctl enable nginx

# Set proper permissions
chown -R www-data:www-data /var/www/html
chmod -R 755 /var/www/html

# Configure logging
mkdir -p /var/log/webserver
chown www-data:www-data /var/log/webserver

echo "Web server setup completed successfully"
