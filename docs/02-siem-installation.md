# SIEM Installation Guide (Wazuh & Suricata)

## System Preparation
On the SIEM Server (`192.168.56.10`), run a full system update:
```bash
sudo apt update && sudo apt upgrade -y
sudo hostnamectl set-hostname wazuh-siem
sudo ufw allow 443/tcp
sudo ufw allow 1514/tcp
sudo ufw allow 1515/tcp
sudo ufw enable
```

## Wazuh All-In-One Installation
We will use the Wazuh installation assistant to deploy the Wazuh Indexer, Manager, and Dashboard on a single node.

```bash
curl -sO https://packages.wazuh.com/4.x/wazuh-install.sh
sudo bash ./wazuh-install.sh -a
```
> [!IMPORTANT]
> The installation script will take several minutes to complete. Once finished, it will output the default `admin` credentials. **Save these credentials immediately.**

### Post-Install Verification
1. Open a web browser on your host machine.
2. Navigate to `https://192.168.56.10`.
3. Accept the self-signed certificate warning.
4. Log in using the `admin` credentials provided by the script.

## Wazuh Agent Installation

### Windows Target (`192.168.56.20`)
Open an administrative PowerShell prompt on the Windows VM and run the following command to download, install, and enroll the agent:
```powershell
Invoke-WebRequest -Uri https://packages.wazuh.com/4.x/windows/wazuh-agent-4.x.msi -OutFile wazuh-agent.msi
msiexec.exe /i wazuh-agent.msi /q WAZUH_MANAGER="192.168.56.10" WAZUH_REGISTRATION_SERVER="192.168.56.10"
NET START WazuhSvc
```

### Linux Target (`192.168.56.30`)
Run the following commands on the Ubuntu target to install the Wazuh agent:
```bash
wget https://packages.wazuh.com/4.x/apt/pool/main/w/wazuh-agent/wazuh-agent_4.x_amd64.deb
sudo WAZUH_MANAGER="192.168.56.10" dpkg -i wazuh-agent_4.x_amd64.deb
sudo systemctl daemon-reload
sudo systemctl enable wazuh-agent
sudo systemctl start wazuh-agent
```

### Agent Verification
Navigate to **Wazuh Dashboard > Wazuh > Agents**. You should see both the Windows and Linux agents listed as `Active`.

---

## Suricata NIDS Installation

We will install Suricata directly on the SIEM server to monitor the Host-Only network traffic.

### Install and Configure Suricata
```bash
sudo add-apt-repository ppa:oisf/suricata-stable
sudo apt update
sudo apt install suricata -y
```

Edit the Suricata configuration file to monitor the correct interface (`enp0s3` or `vboxnet0` depending on your routing, usually `enp0s3` on the VM):
```bash
sudo nano /etc/suricata/suricata.yaml
```
Modify the following sections:
```yaml
af-packet:
  - interface: enp0s3
    cluster-id: 99
    cluster-type: cluster_flow
    defrag: yes
    use-mmap: yes
    tpacket-v3: yes
```

### Update Rulesets
Download and enable the Emerging Threats (ET) Open ruleset:
```bash
sudo suricata-update
sudo systemctl restart suricata
sudo systemctl enable suricata
```

### Configure Wazuh to Ingest Suricata Logs
Wazuh needs to be instructed to read the Suricata `eve.json` log file.
```bash
sudo nano /var/ossec/etc/ossec.conf
```
Add the following block within the `<ossec_config>` section:
```xml
  <localfile>
    <log_format>json</log_format>
    <location>/var/log/suricata/eve.json</location>
  </localfile>
```
Restart the Wazuh Manager:
```bash
sudo systemctl restart wazuh-manager
```

### Verification Test
From the Kali machine (`192.168.56.50`), run a quick Nmap scan against the Windows Target:
```bash
nmap -sS -p 80,443,3389 192.168.56.20
```
Check the Wazuh Dashboard under **Discover** or the **Security Events** module. You should see Suricata alerts being ingested correctly.
