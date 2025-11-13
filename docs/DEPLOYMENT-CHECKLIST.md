# Deployment and Security Hardening Checklist

This checklist ensures all security measures are properly implemented during and after deployment.

## Pre-Deployment

- [ ] AWS account configured with appropriate permissions
- [ ] AWS CLI installed and configured
- [ ] Terraform installed (version >= 1.0)
- [ ] SSH key pair generated
- [ ] Reviewed and customized `variables.tf`
- [ ] Admin IP address identified for SSH access
- [ ] Domain name registered (if using HTTPS)

## Infrastructure Deployment

- [ ] Terraform initialized (`terraform init`)
- [ ] Terraform plan reviewed (`terraform plan`)
- [ ] Infrastructure deployed (`terraform apply`)
- [ ] Deployment outputs saved
- [ ] Public IP address noted
- [ ] EC2 instance accessible via SSH
- [ ] Web server accessible via HTTP

## Initial Security Verification

- [ ] Verify only ports 22, 80, 443 are open
- [ ] Verify SSH access with key works
- [ ] Verify web server responds
- [ ] Check security group rules
- [ ] Verify IAM role attached to instance
- [ ] Confirm EBS encryption enabled
- [ ] Verify IMDSv2 is enforced

## Security Hardening - Critical Priority

### 1. HTTPS/SSL Implementation
- [ ] SSL certificate obtained (Let's Encrypt or ACM)
- [ ] Nginx configured for HTTPS
- [ ] HTTP to HTTPS redirect enabled
- [ ] SSL/TLS configuration tested
- [ ] HSTS header implemented
- [ ] Certificate auto-renewal configured

### 2. SSH Access Restriction
- [ ] Admin IP whitelisted in security group
- [ ] Password authentication disabled
- [ ] Root login disabled
- [ ] SSH key-based authentication only
- [ ] Fail2Ban installed and configured
- [ ] SSH login attempts monitored

## Security Hardening - High Priority

### 3. Security Headers Implementation
- [ ] Content-Security-Policy header added
- [ ] Strict-Transport-Security header added
- [ ] X-Frame-Options header configured
- [ ] X-Content-Type-Options header added
- [ ] X-XSS-Protection header enabled
- [ ] Referrer-Policy header configured
- [ ] Permissions-Policy header added
- [ ] Server tokens disabled

### 4. Rate Limiting and DDoS Protection
- [ ] Nginx rate limiting zones configured
- [ ] Rate limits applied to sensitive endpoints
- [ ] Connection limits configured
- [ ] Fail2Ban rules active
- [ ] CloudWatch alarms for unusual traffic

## Security Hardening - Medium Priority

### 5. Firewall Configuration
- [ ] UFW enabled with default deny
- [ ] Only necessary ports allowed
- [ ] UFW rules verified
- [ ] Firewall logs enabled

### 6. System Hardening
- [ ] Automatic security updates enabled
- [ ] System fully updated (`apt-get update && apt-get upgrade`)
- [ ] Unnecessary services disabled
- [ ] File permissions properly set
- [ ] Logging configured

### 7. Monitoring and Alerting
- [ ] CloudWatch agent installed (optional)
- [ ] Log aggregation configured
- [ ] Alert rules created for:
  - [ ] Failed SSH attempts
  - [ ] High CPU/memory usage
  - [ ] Disk space warnings
  - [ ] SSL certificate expiration

## Penetration Testing

### Reconnaissance Phase
- [ ] Nmap scan completed
- [ ] Service versions identified
- [ ] Web server fingerprinted
- [ ] HTTP headers analyzed
- [ ] Results documented

### Vulnerability Assessment
- [ ] Nikto scan completed
- [ ] SSL/TLS configuration tested
- [ ] Security headers verified
- [ ] Common vulnerabilities checked
- [ ] Findings documented with CVSS scores

### Verification Testing
- [ ] All identified vulnerabilities mitigated
- [ ] Re-scan completed to verify fixes
- [ ] No critical vulnerabilities remaining
- [ ] Security score improved

## Documentation

- [ ] Infrastructure architecture documented
- [ ] Deployment steps documented
- [ ] Security configurations documented
- [ ] Vulnerability findings documented
- [ ] Mitigation steps documented
- [ ] Penetration test report completed
- [ ] README.md updated
- [ ] Contact information added

## Post-Deployment Verification

### Security Scans
- [ ] Nmap scan shows only required ports
- [ ] Nikto scan shows no critical issues
- [ ] SSL Labs test shows A rating or better
- [ ] Security headers check passes
- [ ] No sensitive information disclosed

### Functional Testing
- [ ] Website loads correctly via HTTPS
- [ ] HTTP redirects to HTTPS
- [ ] SSL certificate valid
- [ ] No browser security warnings
- [ ] All security headers present
- [ ] Server version not disclosed

### Access Control
- [ ] SSH accessible only from admin IP
- [ ] Password authentication disabled
- [ ] Web server accessible to public
- [ ] No unauthorized ports open
- [ ] Fail2Ban actively blocking attacks

## Compliance Checks

### OWASP Top 10 (2021)
- [ ] A01:2021 - Broken Access Control: Reviewed
- [ ] A02:2021 - Cryptographic Failures: HTTPS implemented
- [ ] A03:2021 - Injection: Input validation in place
- [ ] A04:2021 - Insecure Design: Secure architecture
- [ ] A05:2021 - Security Misconfiguration: Hardened
- [ ] A06:2021 - Vulnerable Components: Updated
- [ ] A07:2021 - Authentication Failures: Key-based auth
- [ ] A08:2021 - Software Integrity Failures: Verified
- [ ] A09:2021 - Logging Failures: Logging enabled
- [ ] A10:2021 - SSRF: IMDSv2 enforced

### CIS AWS Foundations Benchmark
- [ ] Network configuration follows CIS guidelines
- [ ] IAM policies follow least privilege
- [ ] Encryption enabled for data at rest
- [ ] Logging and monitoring enabled
- [ ] Security groups properly configured

## Ongoing Maintenance

### Daily
- [ ] Automatic security updates applied
- [ ] Monitor for any unusual activity

### Weekly
- [ ] Review security logs
- [ ] Check for failed login attempts
- [ ] Verify backup completion (if configured)
- [ ] Review CloudWatch metrics

### Monthly
- [ ] Run vulnerability scan
- [ ] Review and update security rules
- [ ] Check for software updates
- [ ] Review access logs

### Quarterly
- [ ] Full penetration test
- [ ] Security architecture review
- [ ] Update documentation
- [ ] Review and update security policies

### Annually
- [ ] Comprehensive security audit
- [ ] Disaster recovery test
- [ ] Compliance review
- [ ] Security training review

## Emergency Procedures

### If Compromise Suspected
- [ ] Document incident response steps
- [ ] Emergency contact list maintained
- [ ] Isolation procedures documented
- [ ] Backup and recovery plan tested
- [ ] Incident response team identified

## Sign-off

### Deployment Team
- [ ] Infrastructure deployed and verified
- [ ] Security hardening completed
- [ ] Documentation completed
- [ ] Handoff to operations team

Deployed by: ___________________________  
Date: ___________________________  

### Security Team
- [ ] Penetration testing completed
- [ ] Vulnerability assessment reviewed
- [ ] All critical issues resolved
- [ ] Security approved for production

Approved by: ___________________________  
Date: ___________________________  

### Operations Team
- [ ] Monitoring configured
- [ ] Maintenance schedule established
- [ ] Incident response plan reviewed
- [ ] Ready for production operations

Accepted by: ___________________________  
Date: ___________________________  

---

**Notes:**
- All checklist items should be completed before production deployment
- Document any deviations or exceptions with justification
- Review and update this checklist regularly
- Ensure all team members understand their responsibilities

**Last Updated**: [Date]  
**Version**: 1.0
