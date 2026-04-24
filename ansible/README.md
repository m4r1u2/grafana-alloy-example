# Ansible Alloy Deployment

Ansible role and playbooks to install and configure [Grafana Alloy](https://grafana.com/docs/alloy/latest/) on Linux and Windows VMs using the pre-assembled configs from this repository.

The role is adapted from the [official Grafana Ansible role](https://github.com/grafana/grafana-ansible-collection/tree/main/roles/alloy), simplified and extended with multi-config directory deployment.

## Structure

```
ansible/
├── inventory/
│   └── hosts.yml.example       # Example inventory — copy and fill in
├── playbooks/
│   ├── linux-server.yml         # Deploys Linux OS metrics + logs
│   ├── linux-server-otel.yml    # Linux OS + OTel collector
│   ├── linux-mysql.yml          # Linux + MySQL metrics + logs
│   ├── linux-postgres.yml       # Linux + PostgreSQL metrics + logs
│   ├── linux-springboot.yml     # Linux + Spring Boot + OTel
│   ├── windows-server.yml       # Deploys Windows OS metrics + event logs + OTel
│   └── windows-mssql.yml        # Windows + MSSQL metrics + logs
└── roles/
    └── alloy/                   # Adapted Grafana Alloy role
        ├── defaults/main.yml
        ├── handlers/main.yml
        ├── meta/main.yml
        ├── tasks/
        │   ├── main.yml
        │   ├── preflight.yml
        │   ├── deploy.yml         # Linux deployment
        │   ├── deploy-windows.yml # Windows deployment
        │   ├── setup-Debian.yml
        │   ├── setup-RedHat.yml
        │   ├── uninstall.yml
        │   └── uninstall-windows.yml
        ├── templates/
        │   ├── alloy.j2            # Systemd env file
        │   ├── env-fragment.j2     # Drop-in env.d fragment
        │   ├── config.alloy.j2     # Inline config (if used)
        │   └── override.conf.j2    # Systemd unit override
        └── vars/
            ├── main.yml
            ├── Debian.yml
            ├── RedHat.yml
            └── Windows.yml
```

## Quick Start

### 1. Prerequisites

```bash
# Ansible 2.13+ with required collections
pip install ansible pywinrm

# Linux targets
ansible-galaxy collection install ansible.utils ansible.posix

# Windows targets
ansible-galaxy collection install ansible.windows community.windows
```

### 2. Create inventory

```bash
cp ansible/inventory/hosts.yml.example ansible/inventory/hosts.yml
# Edit hosts.yml with your target hosts, credentials, and Grafana Cloud details
```

### 3. Run the playbook

**Linux:**
```bash
ansible-playbook -i inventory/hosts.yml playbooks/linux-server.yml
```

**Windows:**
```bash
ansible-playbook -i inventory/hosts.yml playbooks/windows-server.yml
```

> **macOS users:** If you get a fork() crash, set `export OBJC_DISABLE_INITIALIZE_FORK_SAFETY=YES` before running.

---

## Windows: WinRM Setup

Ansible connects to Windows via WinRM. The target VM must be configured before Ansible can reach it.

### Option A: HTTPS (recommended — port 5986)

Run these commands in an **elevated PowerShell** on the Windows VM:

```powershell
# 1. Enable WinRM and configure LocalAccountTokenFilterPolicy
winrm quickconfig -Force

# 2. Create a self-signed certificate and HTTPS listener
$cert = New-SelfSignedCertificate -DnsName $env:COMPUTERNAME -CertStoreLocation Cert:\LocalMachine\My
winrm create winrm/config/Listener?Address=*+Transport=HTTPS "@{Hostname=`"$($env:COMPUTERNAME)`";CertificateThumbprint=`"$($cert.Thumbprint)`"}"

# 3. Open the firewall for WinRM HTTPS
netsh advfirewall firewall add rule name="WinRM HTTPS" dir=in action=allow protocol=TCP localport=5986
```

Inventory settings for HTTPS:

```yaml
ansible_connection: winrm
ansible_winrm_transport: ntlm
ansible_winrm_server_cert_validation: ignore   # for self-signed certs
ansible_port: 5986
```

> For production, use a CA-issued certificate instead of a self-signed one and remove `ansible_winrm_server_cert_validation: ignore`.

### Option B: HTTP (test only — port 5985)

```powershell
winrm quickconfig -Force
netsh advfirewall firewall add rule name="WinRM HTTP" dir=in action=allow protocol=TCP localport=5985
```

Inventory settings for HTTP:

```yaml
ansible_connection: winrm
ansible_winrm_transport: ntlm
ansible_port: 5985
```

### Cloud / firewall

If the VM is in Azure, AWS, or behind a firewall, also open port **5986** (or 5985) in the network security group / security group.

---

## What Gets Deployed

### Linux (`linux-server` playbook)

1. **Installs** the Alloy package (deb or rpm, latest version by default)
2. **Copies** the pre-assembled `.alloy` config files to `/etc/alloy/`
3. **Templates** the environment file with your endpoints and labels
4. **Adds** the `alloy` user to `systemd-journal` and `adm` groups (for log access)
5. **Sets ACLs** on `/var/log` for RHEL-family systems
6. **Starts** the service and verifies readiness on `http://127.0.0.1:12345/-/ready`

| File | Source | What it does |
|------|--------|--------------|
| `endpoints.alloy` | `examples/linux-server/` | Prometheus remote_write + Loki endpoints |
| `labels.alloy` | `examples/linux-server/` | Common labels (environment, team, region, system, server_class, zone) |
| `alloy-health.alloy` | `examples/linux-server/` | Alloy self-monitoring metrics and logs |
| `os.alloy` | `examples/linux-server/` | Node exporter metrics, journal logs, file logs |

### Windows (`windows-server` playbook)

1. **Downloads and installs** the Alloy `.exe` installer silently
2. **Copies** the pre-assembled `.alloy` config files to the Alloy install directory
3. **Configures** the registry with startup arguments and environment variables
4. **Sets machine-level environment variables** for `sys.env()` access
5. **Adds** the Alloy service account to `Event Log Readers` and `Performance Monitor Users`
6. **Opens** the firewall port and verifies readiness

| File | Source | What it does |
|------|--------|--------------|
| `endpoints.alloy` | `examples/windows-server/` | Prometheus remote_write + Loki endpoints |
| `labels.alloy` | `examples/windows-server/` | Common labels (environment, team, region, system, server_class, zone) |
| `alloy-health.alloy` | `examples/windows-server/` | Alloy self-monitoring metrics and logs |
| `otel-collector.alloy` | `examples/windows-server/` | OpenTelemetry OTLP receiver + exporter |
| `os.alloy` | `examples/windows-server/` | Windows exporter metrics + event logs |

## Role Variables

See [roles/alloy/defaults/main.yml](roles/alloy/defaults/main.yml) for all available variables.

Key variables for the playbook:

| Variable | Description |
|----------|-------------|
| `prometheus_remote_write_url` | Prometheus/Mimir remote write URL |
| `prometheus_username` / `prometheus_password` | Basic auth credentials |
| `loki_write_url` | Loki push API URL |
| `loki_username` / `loki_password` | Basic auth credentials |
| `environment_label` | Deployment environment (production, staging, dev) |
| `team_label` | Owning team name |
| `region_label` | Deployment region |
| `system_label` | Business system / domain |
| `server_class_label` | Server role (web, app, db, worker) |
| `zone_label` | Network zone / segment |

## Uninstall

**Linux:**
```bash
ansible-playbook -i inventory/hosts.yml playbooks/linux-server.yml -e "alloy_uninstall=true"
```

**Windows:**
```bash
ansible-playbook -i inventory/hosts.yml playbooks/windows-server.yml -e "alloy_uninstall=true"
```

## Adding More Modules

To deploy MySQL, PostgreSQL, or Spring Boot alongside the baseline, use one of the provided playbooks or create a new one with the relevant `.alloy` files in `alloy_config_files`:

```yaml
alloy_config_files:
  - "../examples/linux-mysql/endpoints.alloy"
  - "../examples/linux-mysql/labels.alloy"
  - "../examples/linux-mysql/alloy-health.alloy"
  - "../examples/linux-mysql/os.alloy"
  - "../examples/linux-mysql/mysql.alloy"

alloy_env_files:
  - name: "00-endpoints"
    vars:
      PROMETHEUS_REMOTE_WRITE_URL: "{{ prometheus_remote_write_url }}"
      # ...
  - name: "20-mysql"
    vars:
      MYSQL_DSN: "{{ mysql_dsn }}"
```
