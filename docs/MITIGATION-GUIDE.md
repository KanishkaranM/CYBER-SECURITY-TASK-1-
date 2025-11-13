# Security Vulnerability Mitigation Guide

This document provides step-by-step mitigation strategies for all vulnerabilities identified during the penetration testing phase.

## Table of Contents
1. [Critical Priority Mitigations](#critical-priority-mitigations)
2. [High Priority Mitigations](#high-priority-mitigations)
3. [Medium Priority Mitigations](#medium-priority-mitigations)
4. [Low Priority Mitigations](#low-priority-mitigations)
5. [Verification Steps](#verification-steps)

---

## Critical Priority Mitigations

### 1. Implement HTTPS/SSL Encryption

**Vulnerability**: Missing HTTPS/SSL - CVSS 7.4

**Step-by-Step Mitigation**:

#### Option A: Using Let's Encrypt (Free)

1. **Install Certbot**:
   ```bash
   sudo apt-get update
   sudo apt-get install certbot python3-certbot-nginx
   ```

2. **Obtain SSL Certificate**:
   ```bash
   sudo certbot --nginx -d yourdomain.com -d www.yourdomain.com
   ```

3. **Verify Auto-Renewal**:
   ```bash
   sudo certbot renew --dry-run
   ```

#### Option B: Using AWS Certificate Manager

1. **Request Certificate in ACM**:
   ```bash
   aws acm request-certificate \
     --domain-name yourdomain.com \
     --validation-method DNS \
     --region us-east-1
   ```

2. **Update Terraform to use Application Load Balancer**:
   ```hcl
   resource "aws_lb" "web" {
     name               = "secure-web-lb"
     internal           = false
     load_balancer_type = "application"
     security_groups    = [aws_security_group.lb.id]
     subnets            = [aws_subnet.public_a.id, aws_subnet.public_b.id]
   }

   resource "aws_lb_listener" "https" {
     load_balancer_arn = aws_lb.web.arn
     port              = "443"
     protocol          = "HTTPS"
     ssl_policy        = "ELBSecurityPolicy-TLS-1-2-2017-01"
     certificate_arn   = aws_acm_certificate.cert.arn

     default_action {
       type             = "forward"
       target_group_arn = aws_lb_target_group.web.arn
     }
   }
   ```

#### Manual Nginx Configuration for HTTPS

3. **Edit Nginx Configuration**:
   ```bash
   sudo nano /etc/nginx/sites-available/default
   ```

4. **Add HTTPS Server Block**:
   ```nginx
   server {
       listen 443 ssl http2;
       listen [::]:443 ssl http2;
       
       ssl_certificate /etc/letsencrypt/live/yourdomain.com/fullchain.pem;
       ssl_certificate_key /etc/letsencrypt/live/yourdomain.com/privkey.pem;
       
       ssl_protocols TLSv1.2 TLSv1.3;
       ssl_ciphers HIGH:!aNULL:!MD5;
       ssl_prefer_server_ciphers on;
       
       # HSTS
       add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
       
       root /var/www/html;
       index index.html;
       
       server_name yourdomain.com;
       
       location / {
           try_files $uri $uri/ =404;
       }
   }
   
   # Redirect HTTP to HTTPS
   server {
       listen 80;
       listen [::]:80;
       server_name yourdomain.com;
       return 301 https://$server_name$request_uri;
   }
   ```

5. **Test and Reload**:
   ```bash
   sudo nginx -t
   sudo systemctl reload nginx
   ```

**Verification**:
```bash
# Test SSL configuration
openssl s_client -connect yourdomain.com:443 -servername yourdomain.com

# Check SSL Labs rating
# Visit: https://www.ssllabs.com/ssltest/analyze.html?d=yourdomain.com
```

---

## High Priority Mitigations

### 2. Restrict SSH Access to Specific IPs

**Vulnerability**: SSH Exposed to Internet - CVSS 5.3

**Step-by-Step Mitigation**:

#### Option A: Update AWS Security Group (Terraform)

1. **Update `variables.tf`**:
   ```hcl
   variable "admin_ip" {
     description = "Admin IP address for SSH access"
     type        = string
     default     = "YOUR.IP.ADDRESS/32"  # Replace with your IP
   }
   ```

2. **Apply Changes**:
   ```bash
   terraform apply -var="admin_ip=YOUR.IP.ADDRESS/32"
   ```

#### Option B: Manual AWS Console

1. Navigate to EC2 → Security Groups
2. Select `secure-webserver-sg`
3. Edit Inbound Rules
4. Modify SSH rule:
   - Type: SSH
   - Protocol: TCP
   - Port: 22
   - Source: My IP (or specific IP/CIDR)
5. Save rules

#### Option C: UFW Firewall Configuration

1. **Remove existing SSH rule**:
   ```bash
   sudo ufw delete allow 22/tcp
   ```

2. **Add restricted SSH rule**:
   ```bash
   sudo ufw allow from YOUR.IP.ADDRESS to any port 22
   ```

3. **Verify rules**:
   ```bash
   sudo ufw status numbered
   ```

**Additional SSH Hardening**:

1. **Disable Password Authentication**:
   ```bash
   sudo nano /etc/ssh/sshd_config
   ```
   
   Update:
   ```
   PasswordAuthentication no
   PubkeyAuthentication yes
   PermitRootLogin no
   ```

2. **Restart SSH**:
   ```bash
   sudo systemctl restart sshd
   ```

**Verification**:
```bash
# Test SSH from allowed IP
ssh -i ~/.ssh/secure-webserver-key.pem ubuntu@<SERVER_IP>

# Test from different IP (should fail)
# Use proxy or different network
```

---

## Medium Priority Mitigations

### 3. Implement Content Security Policy

**Vulnerability**: Missing CSP - CVSS 5.4

**Step-by-Step Mitigation**:

1. **Update Nginx Configuration**:
   ```bash
   sudo nano /etc/nginx/sites-available/default
   ```

2. **Add CSP Header**:
   ```nginx
   server {
       # ... existing configuration ...
       
       # Content Security Policy
       add_header Content-Security-Policy "default-src 'self'; script-src 'self' 'unsafe-inline'; style-src 'self' 'unsafe-inline'; img-src 'self' data: https:; font-src 'self'; connect-src 'self'; frame-ancestors 'self'; base-uri 'self'; form-action 'self';" always;
   }
   ```

3. **Test Configuration**:
   ```bash
   sudo nginx -t
   sudo systemctl reload nginx
   ```

**Verification**:
```bash
curl -I https://yourdomain.com | grep Content-Security-Policy
```

---

### 4. Add Missing Security Headers

**Vulnerability**: Missing Security Headers - CVSS 4.3

**Step-by-Step Mitigation**:

1. **Update Nginx Configuration**:
   ```bash
   sudo nano /etc/nginx/sites-available/default
   ```

2. **Add All Security Headers**:
   ```nginx
   server {
       # ... existing configuration ...
       
       # Security Headers
       add_header Strict-Transport-Security "max-age=31536000; includeSubDomains; preload" always;
       add_header X-Frame-Options "SAMEORIGIN" always;
       add_header X-Content-Type-Options "nosniff" always;
       add_header X-XSS-Protection "1; mode=block" always;
       add_header Referrer-Policy "strict-origin-when-cross-origin" always;
       add_header Permissions-Policy "geolocation=(), microphone=(), camera=(), payment=(), usb=(), magnetometer=(), gyroscope=(), speaker=()" always;
       add_header X-Permitted-Cross-Domain-Policies "none" always;
       
       # Remove server version
       server_tokens off;
   }
   ```

3. **Reload Nginx**:
   ```bash
   sudo nginx -t
   sudo systemctl reload nginx
   ```

**Verification**:
```bash
curl -I https://yourdomain.com
```

---

### 5. Implement Rate Limiting

**Vulnerability**: No Rate Limiting - CVSS 5.0

**Step-by-Step Mitigation**:

1. **Update Nginx Main Configuration**:
   ```bash
   sudo nano /etc/nginx/nginx.conf
   ```

2. **Add Rate Limit Zones** (in `http` block):
   ```nginx
   http {
       # Rate limiting zones
       limit_req_zone $binary_remote_addr zone=general:10m rate=10r/s;
       limit_req_zone $binary_remote_addr zone=login:10m rate=5r/m;
       limit_conn_zone $binary_remote_addr zone=addr:10m;
       
       # ... rest of configuration ...
   }
   ```

3. **Apply Rate Limits in Site Configuration**:
   ```nginx
   server {
       # General rate limit
       limit_req zone=general burst=20 nodelay;
       limit_conn addr 10;
       
       # ... existing configuration ...
   }
   ```

4. **Reload Nginx**:
   ```bash
   sudo nginx -t
   sudo systemctl reload nginx
   ```

**Verification**:
```bash
# Test rate limiting
for i in {1..30}; do curl -I https://yourdomain.com; done
# Should see some 503 responses
```

---

## Low Priority Mitigations

### 6. Remove Server Version Information

**Vulnerability**: Information Disclosure - CVSS 3.1

**Step-by-Step Mitigation**:

1. **Update Nginx Configuration**:
   ```nginx
   server {
       server_tokens off;
       # ... rest of configuration ...
   }
   ```

2. **Hide PHP Version** (if applicable):
   ```bash
   sudo nano /etc/php/8.1/fpm/php.ini
   ```
   
   Set:
   ```ini
   expose_php = Off
   ```

3. **Reload Services**:
   ```bash
   sudo nginx -t
   sudo systemctl reload nginx
   sudo systemctl restart php8.1-fpm  # if PHP is installed
   ```

**Verification**:
```bash
curl -I https://yourdomain.com | grep -i server
# Should not show version number
```

---

## Additional Hardening Measures

### 7. Implement Fail2Ban

**Purpose**: Protect against brute force attacks

1. **Install Fail2Ban**:
   ```bash
   sudo apt-get install fail2ban
   ```

2. **Configure Fail2Ban**:
   ```bash
   sudo nano /etc/fail2ban/jail.local
   ```
   
   Add:
   ```ini
   [sshd]
   enabled = true
   port = 22
   filter = sshd
   logpath = /var/log/auth.log
   maxretry = 3
   bantime = 3600
   findtime = 600
   
   [nginx-http-auth]
   enabled = true
   filter = nginx-http-auth
   port = http,https
   logpath = /var/log/nginx/error.log
   
   [nginx-limit-req]
   enabled = true
   filter = nginx-limit-req
   port = http,https
   logpath = /var/log/nginx/error.log
   maxretry = 10
   findtime = 60
   bantime = 3600
   ```

3. **Start Fail2Ban**:
   ```bash
   sudo systemctl enable fail2ban
   sudo systemctl start fail2ban
   ```

**Verification**:
```bash
sudo fail2ban-client status
sudo fail2ban-client status sshd
```

---

### 8. Enable Comprehensive Logging

1. **Configure Nginx Logging**:
   ```nginx
   server {
       access_log /var/log/nginx/access.log combined;
       error_log /var/log/nginx/error.log warn;
       
       # ... rest of configuration ...
   }
   ```

2. **Set Up Log Rotation**:
   ```bash
   sudo nano /etc/logrotate.d/nginx
   ```
   
   Ensure it contains:
   ```
   /var/log/nginx/*.log {
       daily
       missingok
       rotate 52
       compress
       delaycompress
       notifempty
       create 0640 www-data adm
       sharedscripts
       postrotate
           if [ -f /var/run/nginx.pid ]; then
               kill -USR1 `cat /var/run/nginx.pid`
           fi
       endscript
   }
   ```

---

## Verification Steps

### Complete Security Audit

1. **Run Security Headers Check**:
   ```bash
   curl -I https://yourdomain.com
   ```

2. **SSL/TLS Test**:
   ```bash
   # Using testssl.sh
   ./testssl.sh https://yourdomain.com
   
   # Or check SSL Labs
   # https://www.ssllabs.com/ssltest/
   ```

3. **Port Scan Verification**:
   ```bash
   nmap -sV -p- yourdomain.com
   ```

4. **Security Scan**:
   ```bash
   nikto -h https://yourdomain.com
   ```

5. **Verify Fail2Ban**:
   ```bash
   sudo fail2ban-client status
   ```

### Security Checklist

- [ ] HTTPS enabled with valid certificate
- [ ] HTTP redirects to HTTPS
- [ ] HSTS header present
- [ ] SSH restricted to specific IPs
- [ ] Password authentication disabled for SSH
- [ ] Content Security Policy implemented
- [ ] All security headers present
- [ ] Server version hidden
- [ ] Rate limiting configured
- [ ] Fail2Ban running
- [ ] Logging enabled
- [ ] Automatic updates configured
- [ ] Firewall (UFW) active
- [ ] All ports except 80, 443, and SSH closed
- [ ] Regular backups configured

---

## Continuous Security Monitoring

### 1. Set Up AWS CloudWatch Alarms

```bash
# Monitor failed SSH attempts
aws cloudwatch put-metric-alarm \
  --alarm-name ssh-failed-attempts \
  --alarm-description "Alert on multiple failed SSH attempts" \
  --metric-name SSHFailedAttempts \
  --namespace CustomMetrics \
  --statistic Sum \
  --period 300 \
  --threshold 5 \
  --comparison-operator GreaterThanThreshold
```

### 2. Schedule Regular Security Scans

```bash
# Add to crontab
0 2 * * 0 /path/to/security-scan.sh
```

### 3. Update Schedule

- **Daily**: Automatic security updates (unattended-upgrades)
- **Weekly**: Review logs for suspicious activity
- **Monthly**: Full security audit and penetration test
- **Quarterly**: Review and update security policies

---

## Emergency Response

### If Compromise is Suspected

1. **Isolate the server**:
   ```bash
   # Block all incoming traffic except your IP
   sudo ufw default deny incoming
   sudo ufw allow from YOUR_IP to any
   ```

2. **Review logs**:
   ```bash
   sudo grep -i "failed\|error" /var/log/auth.log
   sudo grep -i "failed\|error" /var/log/nginx/error.log
   ```

3. **Check for unauthorized changes**:
   ```bash
   sudo find / -mtime -1 -type f  # Files modified in last 24 hours
   ```

4. **Backup current state** before making changes

5. **Contact security team** or incident response

---

## Conclusion

Following these mitigation steps will significantly improve the security posture of the web server deployment. Regular monitoring and updates are essential to maintain security over time.

**Last Updated**: [Date]  
**Next Review**: [Date + 3 months]
