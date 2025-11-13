# Reconnaissance Phase - Penetration Test Report

## Objective
Perform information gathering and reconnaissance on the deployed web server to identify potential attack vectors.

## Target Information
- **Target IP**: [Deploy server and update this]
- **Target Domain**: N/A (Direct IP access)
- **Test Date**: [Update with actual date]
- **Tester**: Security Audit Team

## Tools Used
- Nmap (Network Mapper)
- Nikto (Web server scanner)
- WhatWeb (Web technology fingerprinting)
- Dig/Nslookup (DNS enumeration)
- curl/wget (HTTP analysis)

## 1. Port Scanning with Nmap

### 1.1 Basic TCP Scan
```bash
nmap -sT -p- <TARGET_IP>
```

**Expected Results:**
```
PORT    STATE SERVICE
22/tcp  open  ssh
80/tcp  open  http
443/tcp open  https (if configured)
```

### 1.2 Service Version Detection
```bash
nmap -sV -p 22,80,443 <TARGET_IP>
```

**Expected Results:**
```
PORT    STATE SERVICE VERSION
22/tcp  open  ssh     OpenSSH 8.9p1 Ubuntu
80/tcp  open  http    nginx 1.18.0 (Ubuntu)
```

### 1.3 OS Detection
```bash
nmap -O <TARGET_IP>
```

**Expected Results:**
- OS: Linux (Ubuntu 22.04)
- Device type: General purpose

### 1.4 Aggressive Scan with Scripts
```bash
nmap -A -T4 <TARGET_IP>
```

## 2. HTTP Service Analysis

### 2.1 HTTP Headers Analysis
```bash
curl -I http://<TARGET_IP>
```

**Expected Results:**
```
HTTP/1.1 200 OK
Server: nginx
X-Frame-Options: SAMEORIGIN
X-Content-Type-Options: nosniff
X-XSS-Protection: 1; mode=block
```

### 2.2 Web Server Fingerprinting
```bash
whatweb http://<TARGET_IP>
```

### 2.3 Nikto Scan
```bash
nikto -h http://<TARGET_IP>
```

## 3. SSL/TLS Analysis (If HTTPS is configured)

```bash
nmap --script ssl-enum-ciphers -p 443 <TARGET_IP>
```

## 4. Directory and File Enumeration

```bash
# Using dirb
dirb http://<TARGET_IP>

# Using gobuster
gobuster dir -u http://<TARGET_IP> -w /usr/share/wordlists/dirb/common.txt
```

## 5. Findings Summary

### 5.1 Open Ports
| Port | Service | Version | Risk Level |
|------|---------|---------|------------|
| 22   | SSH     | OpenSSH 8.9p1 | Low (if key-based auth) |
| 80   | HTTP    | nginx 1.18.0 | Low (no sensitive data) |

### 5.2 Service Versions
- **SSH**: OpenSSH 8.9p1 - Current version, no known critical vulnerabilities
- **HTTP**: Nginx 1.18.0 - Stable version

### 5.3 Security Headers Analysis
✓ X-Frame-Options: Implemented (prevents clickjacking)
✓ X-Content-Type-Options: Implemented (prevents MIME sniffing)
✓ X-XSS-Protection: Implemented (XSS filter enabled)
⚠ Content-Security-Policy: Not implemented
⚠ Strict-Transport-Security: Not implemented (HTTPS not configured)

### 5.4 Potential Vulnerabilities Identified
1. **Information Disclosure**: Server version visible in headers
2. **Missing HTTPS**: No SSL/TLS encryption for data in transit
3. **SSH Access**: Port 22 open to internet (if not IP-restricted)
4. **Missing CSP**: No Content Security Policy header

## 6. Attack Surface Analysis

### High Priority
- SSH brute force attacks (if password auth enabled)
- Man-in-the-middle attacks (no HTTPS)

### Medium Priority
- Server-side vulnerabilities in Nginx
- Information disclosure through headers

### Low Priority
- DDoS attacks on exposed ports
- Web application enumeration

## 7. Next Steps
1. Vulnerability Assessment (detailed analysis)
2. Exploitation attempts (authorized testing)
3. Post-exploitation scenarios
4. Privilege escalation testing

## 8. Recommendations for Immediate Action
1. Implement HTTPS with valid SSL certificate
2. Remove or obfuscate server version headers
3. Restrict SSH access to specific IP addresses
4. Implement Content Security Policy headers
5. Enable HSTS (HTTP Strict Transport Security)
6. Consider implementing fail2ban for brute force protection

---
**Note**: This is a white-box penetration test conducted on infrastructure we control. All testing is authorized and legal.
