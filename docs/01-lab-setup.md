# Lab Setup & Network Configuration

## Prerequisites
To successfully build this lab, your host machine must meet the following minimum requirements:
* **Hypervisor:** [VirtualBox](https://www.virtualbox.org/wiki/Downloads)
* **RAM:** 24 GB or more available on the host
* **Disk Space:** 150 GB minimum available storage

## ISO Downloads
Download the following ISO files before beginning the VM creation process:
1. **Kali Linux:** [Official Kali Linux Installer](https://www.kali.org/get-kali/)
2. **Ubuntu Server 24.04 LTS (SIEM):** [Official Ubuntu Server Download](https://ubuntu.com/download/server)
3. **Ubuntu Server 22.04 LTS (Linux Target):** [Ubuntu 22.04 Archive](https://releases.ubuntu.com/22.04/)
4. **Windows 11 Enterprise Evaluation (Windows Target):** Download from the [Microsoft Evaluation Center](https://www.microsoft.com/en-us/evalcenter/evaluate-windows-11-enterprise). This provides a free, 90-day evaluation license, perfect for home lab environments.

## VirtualBox Host-Only Network Configuration
To ensure our malware and adversary simulations do not impact our actual home network, we will create an isolated network for all VMs.

1. Open VirtualBox and go to **File > Tools > Network Manager**.
2. Under the **Host-Only Networks** tab, click **Create**.
3. Configure the adapter with the following settings:
   * **IPv4 Address:** `192.168.56.1`
   * **IPv4 Network Mask:** `255.255.255.0`
4. **Disable the DHCP Server** (we will configure static IPs manually).

## Virtual Machine Provisioning

Provision the four VMs with the exact specifications listed below. Attach all VM Network Adapters to the **Host-Only Adapter** created in the previous step.

### 1. SIEM Server (Ubuntu Server 24.04)
* **vCPUs:** 2
* **RAM:** 6 GB
* **Disk:** 50 GB
* **Network:** Host-Only Adapter
* **IP Address:** `192.168.56.10`

### 2. Windows Target (Windows 11 Enterprise Eval)
* **vCPUs:** 2
* **RAM:** 4 GB
* **Disk:** 40 GB
* **Network:** Host-Only Adapter
* **IP Address:** `192.168.56.20`

### 3. Linux Target (Ubuntu Server 22.04)
* **vCPUs:** 1
* **RAM:** 2 GB
* **Disk:** 20 GB
* **Network:** Host-Only Adapter
* **IP Address:** `192.168.56.30`

### 4. Attacker Machine (Kali Linux)
* **vCPUs:** 2
* **RAM:** 2 GB
* **Disk:** 25 GB
* **Network:** Host-Only Adapter
* **IP Address:** `192.168.56.50`

## Static IP Configuration

### Ubuntu Servers (SIEM & Linux Target)
Modify the Netplan configuration.
```bash
sudo nano /etc/netplan/00-installer-config.yaml
```
Apply the following (adjust IP for `.10` or `.30`):
```yaml
network:
  version: 2
  ethernets:
    enp0s3:
      dhcp4: no
      addresses: [192.168.56.10/24]
      routes:
        - to: default
          via: 192.168.56.1
      nameservers:
        addresses: [8.8.8.8, 1.1.1.1]
```
Apply changes: `sudo netplan apply`

### Windows Target
1. Open **Control Panel > Network and Sharing Center**.
2. Click on the Ethernet adapter > **Properties** > **Internet Protocol Version 4 (TCP/IPv4)**.
3. Use the following IP address:
   * **IP address:** `192.168.56.20`
   * **Subnet mask:** `255.255.255.0`
   * **Default gateway:** `192.168.56.1`

### Kali Linux
Modify the network interfaces file.
```bash
sudo nano /etc/network/interfaces
```
Add the following:
```text
auto eth0
iface eth0 inet static
    address 192.168.56.50
    netmask 255.255.255.0
    gateway 192.168.56.1
```
Restart networking: `sudo systemctl restart networking`

## Connectivity Verification
From the Kali attacker machine, run ping tests to verify connectivity:
```bash
ping -c 4 192.168.56.10
ping -c 4 192.168.56.20
ping -c 4 192.168.56.30
```
*(Note: You may need to disable the Windows Defender Firewall on the Windows Target to allow ICMP Echo Requests).*

> [!TIP]
> **Take Snapshots!**
> Now that the base OS and networking are configured, power off all VMs and take a "Clean Install" snapshot in VirtualBox. This allows you to easily revert the lab state after completing attack simulations.
