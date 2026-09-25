<div align="center">

# 🖥️ SysInfo API

### A lightweight System Information REST API — built with FastAPI, deployed the real way on RHEL

[![Python](https://img.shields.io/badge/Python-3.12-blue?logo=python&logoColor=white)](https://www.python.org/)
[![FastAPI](https://img.shields.io/badge/FastAPI-API-009688?logo=fastapi&logoColor=white)](https://fastapi.tiangolo.com/)
[![Uvicorn](https://img.shields.io/badge/Uvicorn-ASGI-499848)](https://www.uvicorn.org/)
[![Linux](https://img.shields.io/badge/Linux-RHEL-red?logo=redhat&logoColor=white)](https://www.redhat.com/en/technologies/linux-platforms/enterprise-linux)
[![systemd](https://img.shields.io/badge/systemd-Service_Manager-1F1F1F)](https://systemd.io/)
[![Nginx](https://img.shields.io/badge/Nginx-Reverse_Proxy-009639?logo=nginx&logoColor=white)](https://nginx.org/)
[![psutil](https://img.shields.io/badge/psutil-System_Monitoring-orange)](https://github.com/giampaolo/psutil)

*A hands-on Linux deployment exercise: taking a real Python API from `localhost` to a hardened, production-style RHEL service.*

</div>

---

## 📖 Table of Contents

- [Overview](#-overview)
- [Features](#-features)
- [Request Flow](#-request-flow)
- [API Endpoints](#-api-endpoints)
- [API Documentation](#-api-documentation)
- [Deployment](#-deployment)
  - [Phase 1 — Application Setup](#phase-1--application-setup)
  - [Phase 2 — systemd Service](#phase-2--systemd-service)
  - [Phase 3 — SELinux](#phase-3--selinux)
  - [Phase 4 — Nginx Reverse Proxy](#phase-4--nginx-reverse-proxy)
  - [Firewall Configuration](#-firewall-configuration)
  - [Phase 5 — Bash Script + Cron](#-phase-5--bash-script--cron)
- [Configuration Files](#️-configuration-files)
- [Checking Services](#-checking-services)
- [Logs](#-logs)
- [Testing](#-testing)
- [Deployment Architecture](#-deployment-architecture)
- [Project Structure](#-project-structure)
- [Command Cheat Sheet](#-useful-commands-cheat-sheet)
- [Project Purpose](#-project-purpose)
- [Author](#-author)

---

## 📌 Overview

**SysInfo API** exposes real-time Linux server metrics through a clean REST interface:

| | |
|---|---|
| 🖥️ | System information |
| ⚙️ | CPU usage |
| 🧠 | Memory / RAM usage |
| 💾 | Disk usage |
| 🌐 | Network statistics |
| 🔝 | Top CPU-consuming processes |
| ❤️ | Application health status |

The FastAPI application runs internally on **Uvicorn (`127.0.0.1:8000`)**, with **Nginx** in front as a reverse proxy exposing it over **HTTP port 80**.

### 🔀 Request Flow

```text
Client / Browser / curl
        │  HTTP :80
        ▼
   ┌───────────┐
   │   Nginx   │  Reverse Proxy
   └─────┬─────┘
         │ proxy_pass
         ▼
   ┌───────────────┐
   │ Uvicorn :8000  │  FastAPI App
   └───────┬────────┘
           │
           ▼
        psutil
           │
           ▼
    RHEL Linux System
```

---

## ✨ Features

- RESTful API built with **FastAPI**
- Live Linux system monitoring — CPU, RAM, disk, network
- Top CPU-consuming process tracker
- Health-check endpoint for uptime monitoring
- **Uvicorn** ASGI application server
- **systemd**-managed service (auto-restart, boot startup)
- **Nginx** reverse proxy in front of the app
- **SELinux** policy configuration
- **firewalld** rule configuration
- Automated Nginx log archival via **Bash + Cron**
- Centralized logs through `journalctl`

---

## 📡 API Endpoints

| Method | Endpoint | Description |
|:------:|----------|-------------|
| `GET` | `/health` | Check whether the API is running |
| `GET` | `/system/info` | Basic system information |
| `GET` | `/system/cpu` | CPU usage information |
| `GET` | `/system/memory` | RAM / memory information |
| `GET` | `/system/disk` | Root disk usage |
| `GET` | `/system/network` | Network interface statistics |
| `GET` | `/system/processes` | Top 5 CPU-consuming processes |

<details>
<summary><b>❤️ /health — Health Check</b></summary>

```bash
curl http://127.0.0.1/health
```

```json
{
  "status": "ok",
  "service": "sysinfo-api"
}
```
</details>

<details>
<summary><b>🖥️ /system/info — System Information</b></summary>

```bash
curl http://127.0.0.1/system/info
```

```json
{
  "hostname": "MUET",
  "platform": "Linux",
  "platform_version": "#1 SMP PREEMPT_DYNAMIC ...",
  "architecture": "x86_64",
  "uptime": "1h 6m 53s",
  "timestamp": "2026-09-25T09:18:52.905349"
}
```
</details>

<details>
<summary><b>⚙️ /system/cpu — CPU Information</b></summary>

```bash
curl http://127.0.0.1/system/cpu
```
</details>

<details>
<summary><b>🧠 /system/memory — Memory Information</b></summary>

```bash
curl http://127.0.0.1/system/memory
```
</details>

<details>
<summary><b>💾 /system/disk — Disk Information</b></summary>

```bash
curl http://127.0.0.1/system/disk
```
</details>

<details>
<summary><b>🌐 /system/network — Network Information</b></summary>

```bash
curl http://127.0.0.1/system/network
```
</details>

<details>
<summary><b>🔝 /system/processes — Top Processes</b></summary>

```bash
curl http://127.0.0.1/system/processes
```
</details>

---

## 📖 API Documentation

Because the application uses FastAPI, interactive docs are generated automatically:

| Docs | URL |
|---|---|
| Swagger UI | `http://127.0.0.1/docs` |
| ReDoc | `http://127.0.0.1/redoc` |
| OpenAPI spec | `curl http://127.0.0.1/openapi.json` |

---

## 🚀 Deployment

Deployed on a **Red Hat Enterprise Linux (RHEL)** server across **five phases**:

```text
Phase 1  Application Setup  →  Phase 2  systemd Service  →  Phase 3  SELinux
   →  Phase 4  Nginx Reverse Proxy  →  Phase 5  Bash Script + Cron
```

### Phase 1 — Application Setup

The Python application was prepared inside an isolated virtual environment.

```bash
# Create virtual environment
python3.12 -m venv venv

# Activate it
source venv/bin/activate

# Install dependencies
pip install -r requirements.txt
```

> The virtual environment keeps the application's Python dependencies isolated from the system Python installation.

### Phase 2 — systemd Service

A systemd service runs the API as a proper Linux service instead of a manually-started process.

**Config:** `/etc/systemd/system/sysinfo-api.service`

**Runs:** `/opt/sysinfo-api/venv/bin/python3.12 -m uvicorn app.main:app` on `127.0.0.1:8000`

```bash
sudo systemctl daemon-reload
sudo systemctl start sysinfo-api
sudo systemctl enable sysinfo-api
sudo systemctl status sysinfo-api

# Restart / stop
sudo systemctl restart sysinfo-api
sudo systemctl stop sysinfo-api
```

### Phase 3 — SELinux

RHEL enforces **SELinux** as an additional security layer. The application paths were given the correct SELinux file context, and Nginx was permitted to talk to the local FastAPI backend:

```bash
sudo setsebool -P httpd_can_network_connect 1
```

This allows the Nginx/httpd SELinux domain to make network connections — required for the reverse-proxy setup.

```bash
# Check for AVC denials
sudo ausearch -m AVC -ts recent
```

During testing, no AVC denial was reported: `<no matches>` ✅

### Phase 4 — Nginx Reverse Proxy

Instead of clients hitting `127.0.0.1:8000` directly, Nginx receives requests on `http://server/` and forwards them to FastAPI/Uvicorn.

**Config:** `/etc/nginx/conf.d/sysinfo-api.conf`

```nginx
server {
    listen 80;
    server_name _;

    access_log /var/log/nginx/sysinfo-api.access.log;
    error_log  /var/log/nginx/sysinfo-api.error.log;

    location / {
        proxy_pass http://127.0.0.1:8000;

        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;

        proxy_read_timeout 60s;
    }

    location /health {
        proxy_pass http://127.0.0.1:8000/health;
        access_log off;
    }
}
```

```bash
sudo nginx -t                    # Test configuration
sudo systemctl enable nginx      # Enable on boot
sudo systemctl start nginx       # Start
sudo systemctl reload nginx      # Reload after config changes
sudo systemctl status nginx      # Check status
```

#### 🔄 Why Nginx?

```text
Client → Nginx :80 → Uvicorn :8000 → FastAPI
```

Nginx sits in front of Uvicorn as the public-facing web server, handling:

- Reverse proxying & request handling
- SSL/TLS termination
- Static files
- Rate limiting & load balancing

...freeing the FastAPI app to focus purely on application logic.

### 🔥 Firewall Configuration

RHEL uses **firewalld**; the public zone was opened for HTTP.

```bash
sudo firewall-cmd --get-default-zone         # Check active zone
sudo firewall-cmd --list-all                 # Check configuration
sudo firewall-cmd --permanent --add-service=http
sudo firewall-cmd --reload
```

After configuration, `http` appears in the enabled services:

```text
services: cockpit dhcpv6-client http ssh
```

| Service | Binding |
|---|---|
| FastAPI/Uvicorn | `127.0.0.1:8000` (internal only) |
| Nginx | `0.0.0.0:80` (public) |

### 📝 Phase 5 — Bash Script + Cron

A Bash script (`scripts/archive_logs.sh`) automates Nginx access-log rotation:

1. Checks whether the Nginx log exists
2. Checks whether it contains data
3. Compresses the log with `gzip`
4. Stores the compressed archive
5. Clears the original log
6. Logs the operation to `/var/log/archive_logs.log`
7. Deletes archives older than 30 days

```bash
chmod +x scripts/archive_logs.sh   # Make executable
sudo bash scripts/archive_logs.sh  # Run manually
```

**Example output:**

```text
Fri Sep 25 09:42:26 AM PKT 2026:
Archived to /var/log/nginx/archives/access_20260925_094226.log.gz

Fri Sep 25 09:42:26 AM PKT 2026:
Cleanup complete.
```

#### ⏰ Cron Job

Runs every Sunday at 2:00 AM.

```bash
sudo crontab -e
```

```cron
0 2 * * 0 /home/your-linux-username/sysinfo-api/scripts/archive_logs.sh
```

```bash
sudo crontab -l   # Verify
```

> Replace `your-linux-username` with the actual Linux username/path used on the server.

---

## ⚙️ Configuration Files

| File | Location | Purpose |
|---|---|---|
| `sysinfo-api.service` | `/etc/systemd/system/sysinfo-api.service` | Manages the FastAPI app as a Linux service — user, working directory, start command, restart policy, logging, boot startup |
| `sysinfo-api.conf` | `/etc/nginx/conf.d/sysinfo-api.conf` | Tells Nginx to receive HTTP on port `80` and forward to `127.0.0.1:8000` |

<details>
<summary><b>View <code>sysinfo-api.service</code></b></summary>

```ini
[Unit]
Description=SysInfo FastAPI Application
After=network.target

[Service]
Type=simple
User=skhuhro
WorkingDirectory=/opt/sysinfo-api
ExecStart=/opt/sysinfo-api/venv/bin/python3.12 -m uvicorn app.main:app --host 127.0.0.1 --port 8000
Restart=on-failure
RestartSec=5s
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
```
</details>

---

## 📋 Checking Services

```bash
sudo systemctl status sysinfo-api   # FastAPI service
sudo systemctl status nginx         # Nginx
sudo ss -ltnp                       # Listening ports
```

**Example port layout:**

```text
*:80              → Nginx
127.0.0.1:8000    → FastAPI/Uvicorn
*:8081            → Apache/httpd
```

---

## 📜 Logs

| Log | Path | View |
|---|---|---|
| FastAPI / systemd | via `journalctl` | `sudo journalctl -u sysinfo-api -n 30 --no-pager` |
| ↳ Follow live | — | `sudo journalctl -u sysinfo-api -f` |
| ↳ Since today | — | `sudo journalctl -u sysinfo-api --since today` |
| Nginx access | `/var/log/nginx/sysinfo-api.access.log` | `sudo tail -f /var/log/nginx/sysinfo-api.access.log` |
| Nginx error | `/var/log/nginx/sysinfo-api.error.log` | `sudo tail -f /var/log/nginx/sysinfo-api.error.log` |
| Archive script | `/var/log/archive_logs.log` | `sudo tail -f /var/log/archive_logs.log` |
| Archived logs | `/var/log/nginx/archives/` | `sudo ls -lh /var/log/nginx/archives/` |

---

## 🧪 Testing

```bash
curl http://127.0.0.1:8000/health     # Direct to FastAPI
curl http://127.0.0.1/health          # Through Nginx
curl http://127.0.0.1/system/info
curl http://127.0.0.1/system/cpu
curl http://127.0.0.1/system/memory
curl http://127.0.0.1/system/disk
curl http://127.0.0.1/system/network
curl http://127.0.0.1/system/processes
```

---

## 🔐 Deployment Architecture

```text
                           RHEL SERVER
┌──────────────────────────────────────────────────────┐
│                                                        │
│   Port 80 ──►  ┌─────────────────────┐                │
│                │        NGINX        │                │
│                │    Reverse Proxy    │                │
│                └──────────┬──────────┘                │
│                           │ 127.0.0.1:8000             │
│                           ▼                            │
│                ┌─────────────────────┐                 │
│                │ Uvicorn + FastAPI   │                 │
│                │  systemd service    │                 │
│                └──────────┬──────────┘                 │
│                           │                             │
│                           ▼                             │
│                      ┌─────────┐                        │
│                      │ psutil  │                        │
│                      └────┬────┘                        │
│                           ▼                             │
│                     Linux System                        │
│                                                          │
│   SELinux   ──► Security                                │
│   firewalld ──► Network Access                          │
│   Cron      ──► Scheduled Log Archive                   │
│                                                          │
└──────────────────────────────────────────────────────┘
```

---

## 📂 Project Structure

```text
sysinfo-api/
├── app/
│   ├── main.py
│   └── routes/
│       ├── health.py
│       └── system.py
├── logs/
├── scripts/
│   └── archive_logs.sh
├── venv/
├── README.md
├── requirements.txt
└── requirements-lock.txt
```

---

## 🔧 Useful Commands Cheat Sheet

<table>
<tr><th>Category</th><th>Commands</th></tr>
<tr>
<td>Application</td>
<td>

```bash
sudo systemctl start sysinfo-api
sudo systemctl stop sysinfo-api
sudo systemctl restart sysinfo-api
sudo systemctl status sysinfo-api
```
</td>
</tr>
<tr>
<td>Nginx</td>
<td>

```bash
sudo nginx -t
sudo systemctl start nginx
sudo systemctl reload nginx
sudo systemctl restart nginx
sudo systemctl status nginx
```
</td>
</tr>
<tr>
<td>Firewall</td>
<td>

```bash
sudo firewall-cmd --list-all
sudo firewall-cmd --reload
sudo firewall-cmd --permanent --add-service=http
```
</td>
</tr>
<tr>
<td>SELinux</td>
<td>

```bash
getenforce
sudo ausearch -m AVC -ts recent
sudo setsebool -P httpd_can_network_connect 1
```
</td>
</tr>
<tr>
<td>Ports</td>
<td>

```bash
sudo ss -ltnp
```
</td>
</tr>
<tr>
<td>Logs</td>
<td>

```bash
sudo journalctl -u sysinfo-api -f
sudo tail -f /var/log/nginx/sysinfo-api.access.log
sudo tail -f /var/log/nginx/sysinfo-api.error.log
```
</td>
</tr>
</table>

---

## 🎯 Project Purpose

Created as a practical **Linux/DevOps deployment exercise**, this project traces the complete path from a Python application to a managed, production-style Linux service:

```text
Python Application → Virtual Environment → Uvicorn → systemd
   → SELinux → Nginx Reverse Proxy → firewalld → Bash + Cron Log Management
```

---

## 👨‍💻 Author

**Sameer Khuhro**
BE Software Engineering — Mehran University of Engineering & Technology (MUET)

<div align="center">

### 🚀 Built, Deployed & Tested on Red Hat Enterprise Linux

**Python • FastAPI • Uvicorn • psutil • RHEL • systemd • Nginx • SELinux • firewalld • Bash • Cron**

</div>
