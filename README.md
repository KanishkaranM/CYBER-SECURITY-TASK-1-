# Task 1 — Local Network Port Scan

**Objective:** Discover open ports on devices in my local network and analyze exposure.

**Tools used:** Nmap, Wireshark (optional)

**Commands run (examples):**
- `sudo nmap -sS -T4 --open -p- -oA scan_local # Task 1 — Local Network Port Scan

**Objective:** Discover open ports on devices in my local network and analyze exposure.

**Tools used:** Nmap, Wireshark (optional)

**Commands run (examples):**
- `sudo nmap -sS -T4 --open -p- -oA scan_local 1# Task 1 — Local Network Port Scan

**Objective:** Discover open ports on devices in my local network and analyze exposure.

**Tools used:** Nmap, Wireshark (optional)

**Commands run (examples):**
- `sudo nmap -sS -T4 --open -p- -oA scan_local 192.168.1.0/24`
- <img src="./screenshots/nmap_terminal.png" width="600">
- `sudo nmap -sS -sV -O -p 22,80,443 192.168.1.10 -oN host_192.168.1.10.txt`
- <img src="./screenshots/nmap_terminal.png" width="600">
- `sudo nmap -sU -T3 --open -p 1-2000 192.168.1.0/24 -oN udp_scan.txt`
- <img src="./screenshots/nmap_terminal.png" width="600">

**Files in this repo:**
- `scan_local.nmap`, `scan_local.xml`, `scan_local_readable.txt` — Nmap outputs
- `wireshark_capture.pcap` — packet capture (optional)
- `screenshots/` — screenshots of terminal and Wireshark

**Summary of findings:**
- 192.168.1.10 — ports open: 22 (ssh), 80 (http). Risk: default SSH and HTTP exposed from local network; ensure strong passwords and update web apps.
- 192.168.1.15 — port open: 445 (SMB). Risk: SMB exposure; restrict with firewall.

**Recommendations / Remediation:**
1. Close or restrict unused services via firewall (ufw/Windows Firewall).
2. Apply updates to services (patch known CVEs).
3. Use strong authentication (disable telnet, use key-based SSH, use HTTPS).
4. Use network segmentation and VLANs for IoT devices.

**Ethical note:** All scans were performed only on devices I own (or with permission).

4`
- `sudo nmap -sS -sV -O -p 22,80,443 192.168.1.10 -oN host_192.168.1.10.txt`
- `sudo nmap -sU -T3 --open -p 1-2000 192.168.1.0/24 -oN udp_scan.txt`

**Files in this repo:**
- `scan_local.nmap`, `scan_local.xml`, `scan_local_readable.txt` — Nmap outputs
- `wireshark_capture.pcap` — packet capture (optional)
- `screenshots/` — screenshots of terminal and Wireshark

**Summary of findings:**
- 192.168.1.10 — ports open: 22 (ssh), 80 (http). Risk: default SSH and HTTP exposed from local network; ensure strong passwords and update web apps.
- 192.168.1.15 — port open: 445 (SMB). Risk: SMB exposure; restrict with firewall.

**Recommendations / Remediation:**
1. Close or restrict unused services via firewall (ufw/Windows Firewall).
2. Apply updates to services (patch known CVEs).
3. Use strong authentication (disable telnet, use key-based SSH, use HTTPS).
4. Use network segmentation and VLANs for IoT devices.

**Ethical note:** All scans were performed only on devices I own (or with permission).

`
- `sudo nmap -sS -sV -O -p 22,80,443 192.168.1.10 -oN host_192.168.1.10.txt`
- `sudo nmap -sU -T3 --open -p 1-2000 192.168.1.0/24 -oN udp_scan.txt`

**Files in this repo:**
- `scan_local.nmap`, `scan_local.xml`, `scan_local_readable.txt` — Nmap outputs
- `wireshark_capture.pcap` — packet capture (optional)
- `screenshots/` — screenshots of terminal and Wireshark

**Summary of findings:**
- 192.168.1.10 — ports open: 22 (ssh), 80 (http). Risk: default SSH and HTTP exposed from local network; ensure strong passwords and update web apps.
- 192.168.1.15 — port open: 445 (SMB). Risk: SMB exposure; restrict with firewall.

**Recommendations / Remediation:**
1. Close or restrict unused services via firewall (ufw/Windows Firewall).
2. Apply updates to services (patch known CVEs).
3. Use strong authentication (disable telnet, use key-based SSH, use HTTPS).
4. Use network segmentation and VLANs for IoT devices.

**Ethical note:** All scans were performed only on devices I own (or with permission).

