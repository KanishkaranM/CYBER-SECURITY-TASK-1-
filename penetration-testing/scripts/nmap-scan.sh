#!/bin/bash
# Comprehensive Nmap scanning script for penetration testing
# Usage: ./nmap-scan.sh <TARGET_IP>

set -e

if [ -z "$1" ]; then
    echo "Usage: $0 <TARGET_IP>"
    exit 1
fi

TARGET_IP=$1
OUTPUT_DIR="./nmap-results"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

# Create output directory
mkdir -p "$OUTPUT_DIR"

echo "============================================"
echo "Starting Nmap Scan on: $TARGET_IP"
echo "Timestamp: $TIMESTAMP"
echo "============================================"

# 1. Quick TCP Scan
echo "[*] Running quick TCP scan..."
nmap -T4 -F "$TARGET_IP" -oN "$OUTPUT_DIR/${TIMESTAMP}_quick_scan.txt"

# 2. Full TCP Port Scan
echo "[*] Running full TCP port scan (this may take a while)..."
nmap -p- "$TARGET_IP" -oN "$OUTPUT_DIR/${TIMESTAMP}_full_tcp_scan.txt"

# 3. Service Version Detection
echo "[*] Running service version detection..."
nmap -sV "$TARGET_IP" -oN "$OUTPUT_DIR/${TIMESTAMP}_service_version.txt"

# 4. OS Detection
echo "[*] Running OS detection..."
sudo nmap -O "$TARGET_IP" -oN "$OUTPUT_DIR/${TIMESTAMP}_os_detection.txt" || echo "Note: OS detection requires root privileges"

# 5. Aggressive Scan with NSE Scripts
echo "[*] Running aggressive scan with scripts..."
nmap -A -T4 "$TARGET_IP" -oN "$OUTPUT_DIR/${TIMESTAMP}_aggressive_scan.txt"

# 6. Vulnerability Scan
echo "[*] Running vulnerability scripts..."
nmap --script vuln "$TARGET_IP" -oN "$OUTPUT_DIR/${TIMESTAMP}_vulnerability_scan.txt"

# 7. HTTP Enumeration
echo "[*] Running HTTP enumeration scripts..."
nmap --script http-enum,http-headers,http-methods,http-robots.txt -p 80,443,8080 "$TARGET_IP" -oN "$OUTPUT_DIR/${TIMESTAMP}_http_enum.txt"

# 8. SSH Audit
echo "[*] Running SSH audit scripts..."
nmap --script ssh-auth-methods,ssh-hostkey,ssh2-enum-algos -p 22 "$TARGET_IP" -oN "$OUTPUT_DIR/${TIMESTAMP}_ssh_audit.txt"

# 9. SSL/TLS Analysis
echo "[*] Running SSL/TLS analysis..."
nmap --script ssl-cert,ssl-enum-ciphers,ssl-known-key -p 443 "$TARGET_IP" -oN "$OUTPUT_DIR/${TIMESTAMP}_ssl_analysis.txt"

# 10. Generate Summary Report
echo "[*] Generating summary report..."
cat > "$OUTPUT_DIR/${TIMESTAMP}_summary.txt" << EOF
Nmap Scan Summary Report
========================
Target: $TARGET_IP
Date: $(date)
Scan Duration: [Check individual scan files]

Files Generated:
1. ${TIMESTAMP}_quick_scan.txt - Quick TCP scan results
2. ${TIMESTAMP}_full_tcp_scan.txt - Complete port scan
3. ${TIMESTAMP}_service_version.txt - Service detection
4. ${TIMESTAMP}_os_detection.txt - OS fingerprinting
5. ${TIMESTAMP}_aggressive_scan.txt - Aggressive scan with scripts
6. ${TIMESTAMP}_vulnerability_scan.txt - Vulnerability assessment
7. ${TIMESTAMP}_http_enum.txt - HTTP service enumeration
8. ${TIMESTAMP}_ssh_audit.txt - SSH configuration audit
9. ${TIMESTAMP}_ssl_analysis.txt - SSL/TLS analysis

Review each file for detailed findings.
EOF

echo "============================================"
echo "Scan completed successfully!"
echo "Results saved to: $OUTPUT_DIR"
echo "Summary: $OUTPUT_DIR/${TIMESTAMP}_summary.txt"
echo "============================================"
