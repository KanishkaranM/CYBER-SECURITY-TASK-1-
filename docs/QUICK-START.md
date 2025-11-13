# Quick Start Guide

Get up and running with the secure web server deployment in under 10 minutes.

## Prerequisites Check

Before starting, ensure you have:

```bash
# Check AWS CLI
aws --version
# Expected: aws-cli/2.x.x or higher

# Check Terraform
terraform version
# Expected: Terraform v1.0.0 or higher

# Check SSH key
ls ~/.ssh/
# Should have an SSH key pair
```

If any are missing, see [Installation Instructions](#installation-instructions) below.

---

## Deployment in 5 Steps

### Step 1: Clone the Repository

```bash
git clone https://github.com/KanishkaranM/CYBER-SECURITY-TASK-1-.git
cd CYBER-SECURITY-TASK-1-
```

### Step 2: Configure AWS Credentials

```bash
aws configure
# Enter your AWS Access Key ID
# Enter your AWS Secret Access Key
# Enter your default region (e.g., us-east-1)
# Enter your output format (json)
```

### Step 3: Create SSH Key Pair

```bash
# Create key pair in AWS
aws ec2 create-key-pair \
  --key-name secure-webserver-key \
  --query 'KeyMaterial' \
  --output text > ~/.ssh/secure-webserver-key.pem

# Set proper permissions
chmod 400 ~/.ssh/secure-webserver-key.pem
```

### Step 4: Deploy Infrastructure

```bash
cd infrastructure/aws/terraform

# Initialize Terraform
terraform init

# Deploy (auto-approve for quick start)
terraform apply -auto-approve
```

Wait 3-5 minutes for deployment to complete.

### Step 5: Get Your Server URL

```bash
# Get the public IP
terraform output web_server_public_ip

# Get the full URL
terraform output web_server_url
```

**🎉 Done!** Open the URL in your browser to see your secure web server.

---

## Access Your Server

### Via Web Browser

```bash
# Open in browser
http://<your-public-ip>
```

### Via SSH

```bash
# Get the IP from Terraform
IP=$(terraform output -raw web_server_public_ip)

# Connect via SSH
ssh -i ~/.ssh/secure-webserver-key.pem ubuntu@$IP
```

---

## Next Steps - Security Hardening

### 1. Restrict SSH Access (CRITICAL)

By default, SSH is open to all IPs. Restrict it to your IP:

```bash
# Get your current IP
MY_IP=$(curl -s ifconfig.me)

# Update Terraform
cd infrastructure/aws/terraform
terraform apply -var="admin_ip=${MY_IP}/32"
```

### 2. Implement HTTPS (CRITICAL)

If you have a domain name:

```bash
# SSH into the server
ssh -i ~/.ssh/secure-webserver-key.pem ubuntu@<PUBLIC_IP>

# Install Certbot
sudo apt-get update
sudo apt-get install -y certbot python3-certbot-nginx

# Get SSL certificate
sudo certbot --nginx -d yourdomain.com
```

### 3. Apply All Security Mitigations

```bash
# SSH into the server
ssh -i ~/.ssh/secure-webserver-key.pem ubuntu@<PUBLIC_IP>

# Run the hardening script (create this from mitigation guide)
# Or follow the step-by-step guide in docs/MITIGATION-GUIDE.md
```

---

## Verify Deployment

### Quick Security Check

```bash
# From your local machine

# Check open ports
nmap -p- <PUBLIC_IP>
# Should show: 22, 80 (and 443 if HTTPS configured)

# Check web server
curl -I http://<PUBLIC_IP>
# Should return 200 OK

# Check SSH
ssh -i ~/.ssh/secure-webserver-key.pem ubuntu@<PUBLIC_IP> echo "SSH works"
```

### Run Penetration Tests

```bash
cd penetration-testing/scripts

# Run Nmap scan
./nmap-scan.sh <PUBLIC_IP>

# Run web vulnerability scan
./web-vulnerability-scan.sh http://<PUBLIC_IP>

# Review results
ls -la ./nmap-results/
ls -la ./web-scan-results/
```

---

## Cleanup

When you're done testing, destroy all resources:

```bash
cd infrastructure/aws/terraform
terraform destroy -auto-approve
```

**Note**: This will delete ALL resources created by Terraform.

---

## Troubleshooting

### Terraform Apply Fails

**Error**: "Insufficient permissions"
```bash
# Check AWS credentials
aws sts get-caller-identity

# Ensure your IAM user has EC2, VPC, and IAM permissions
```

**Error**: "Key pair already exists"
```bash
# Use a different key name or delete the existing one
aws ec2 delete-key-pair --key-name secure-webserver-key
```

### Cannot SSH to Server

**Error**: "Permission denied (publickey)"
```bash
# Check key permissions
ls -l ~/.ssh/secure-webserver-key.pem
# Should show -r-------- (400)

# Fix permissions
chmod 400 ~/.ssh/secure-webserver-key.pem
```

**Error**: "Connection timed out"
```bash
# Check security group allows your IP
# Update admin_ip variable in Terraform
terraform apply -var="admin_ip=$(curl -s ifconfig.me)/32"
```

### Web Server Not Responding

```bash
# SSH into the server
ssh -i ~/.ssh/secure-webserver-key.pem ubuntu@<PUBLIC_IP>

# Check Nginx status
sudo systemctl status nginx

# Check Nginx logs
sudo tail -f /var/log/nginx/error.log

# Restart Nginx if needed
sudo systemctl restart nginx
```

---

## Installation Instructions

### Install AWS CLI

**Linux/macOS**:
```bash
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
```

**Windows**: Download from https://aws.amazon.com/cli/

### Install Terraform

**Linux**:
```bash
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install terraform
```

**macOS**:
```bash
brew tap hashicorp/tap
brew install hashicorp/tap/terraform
```

**Windows**: Download from https://www.terraform.io/downloads

---

## Cost Estimate

Estimated AWS costs for this deployment:

| Resource | Monthly Cost (USD) |
|----------|-------------------|
| EC2 t2.micro | $8-10 |
| EBS 20GB gp3 | $2 |
| Elastic IP | $0 (while attached) |
| Data Transfer | $1-5 (depending on usage) |
| **Total** | **~$11-17/month** |

**Note**: If you're within AWS Free Tier limits, many of these resources are free for the first 12 months.

---

## Important Security Reminders

⚠️ **Before Going to Production**:

1. ✅ Implement HTTPS with valid SSL certificate
2. ✅ Restrict SSH to your specific IP address
3. ✅ Enable all security headers
4. ✅ Configure rate limiting
5. ✅ Set up monitoring and alerts
6. ✅ Review all security group rules
7. ✅ Test fail2ban is working
8. ✅ Verify automatic updates are enabled

---

## Learning Resources

### Documentation
- [Full README](../README.md) - Complete project documentation
- [Infrastructure README](../infrastructure/aws/terraform/README.md) - Detailed AWS setup
- [Mitigation Guide](./MITIGATION-GUIDE.md) - Step-by-step security hardening
- [Deployment Checklist](./DEPLOYMENT-CHECKLIST.md) - Complete checklist

### Reports
- [Reconnaissance Report](../penetration-testing/reports/reconnaissance-phase.md)
- [Vulnerability Assessment](../penetration-testing/reports/vulnerability-assessment.md)
- [Exploitation Phase](../penetration-testing/reports/exploitation-phase.md)

---

## Support

If you encounter issues:

1. Check the [Troubleshooting](#troubleshooting) section above
2. Review the detailed documentation in `/docs`
3. Check AWS CloudWatch logs
4. Open an issue on GitHub

---

## What's Next?

Once your basic deployment is working:

1. 📖 Read the [full README](../README.md) to understand the architecture
2. 🔒 Follow the [Mitigation Guide](./MITIGATION-GUIDE.md) to harden security
3. 🎯 Run the penetration tests to verify security
4. ✅ Complete the [Deployment Checklist](./DEPLOYMENT-CHECKLIST.md)
5. 📊 Review the vulnerability reports to understand security considerations

---

**Happy Deploying! 🚀**

*Remember: This is a learning project. Always follow security best practices for production deployments.*
