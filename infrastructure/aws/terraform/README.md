# AWS Infrastructure Deployment

This directory contains Terraform configurations for deploying a secure web server on AWS.

## Prerequisites

- AWS account with appropriate permissions
- AWS CLI configured with credentials
- Terraform >= 1.0
- SSH key pair for EC2 access

## Security Features

### Principle of Least Privilege Implementation

1. **Network Security**
   - VPC with isolated subnets
   - Security groups with minimal required ports (80, 443, 22)
   - Private subnet for sensitive resources

2. **IAM Security**
   - EC2 instance role with minimal CloudWatch logging permissions only
   - No unnecessary AWS service access
   - Assumes role policy restricted to EC2 service

3. **Instance Security**
   - EBS encryption enabled
   - IMDSv2 enforced (prevents SSRF attacks)
   - Detailed monitoring enabled
   - Firewall (UFW) configured
   - Fail2Ban for intrusion prevention

## Deployment Steps

1. **Initialize Terraform**
   ```bash
   cd infrastructure/aws/terraform
   terraform init
   ```

2. **Create SSH Key Pair**
   ```bash
   aws ec2 create-key-pair --key-name secure-webserver-key --query 'KeyMaterial' --output text > ~/.ssh/secure-webserver-key.pem
   chmod 400 ~/.ssh/secure-webserver-key.pem
   ```

3. **Update Variables** (Optional)
   Edit `variables.tf` to customize:
   - AWS region
   - Instance type
   - Admin IP for SSH access (recommended to restrict)

4. **Plan Deployment**
   ```bash
   terraform plan
   ```

5. **Apply Configuration**
   ```bash
   terraform apply
   ```

6. **Get Outputs**
   ```bash
   terraform output
   ```

## Post-Deployment

After deployment, you can access:
- Web server: `http://<public_ip>`
- SSH: `ssh -i ~/.ssh/secure-webserver-key.pem ubuntu@<public_ip>`

## Cleanup

To destroy all resources:
```bash
terraform destroy
```

## Security Considerations

- **SSH Access**: Default configuration allows SSH from any IP (0.0.0.0/0). Update `admin_ip` variable to your specific IP address.
- **HTTPS**: Production deployments should use SSL/TLS certificates. Configure AWS Certificate Manager and update the configuration.
- **Monitoring**: Enable AWS CloudWatch alerts for suspicious activities.
- **Backup**: Configure automated backups for critical data.
