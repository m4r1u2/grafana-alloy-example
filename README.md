# Grafana Alloy Configuration Examples

Modular, composable [Grafana Alloy](https://grafana.com/docs/alloy/latest/) configuration for classic VMs. Designed for large organizations where different teams (platform, DBA, application) own different layers of the observability stack.

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                     Grafana Cloud / Stack                    │
│  ┌─────────────┐  ┌──────────┐  ┌──────────┐  ┌─────────┐ │
│  │ Prometheus / │  │          │  │          │  │         │ │
│  │    Mimir     │  │   Loki   │  │  Tempo   │  │ Grafana │ │
│  └──────▲───────┘  └────▲─────┘  └────▲─────┘  └─────────┘ │
└─────────┼───────────────┼──────────────┼────────────────────┘
          │               │              │
          │  remote_write │  loki push   │  OTLP
          │               │              │
┌─────────┴───────────────┴──────────────┴────────────────────┐
│                       Grafana Alloy                          │
│                                                              │
│  ┌──────────┐  ┌──────────────┐  ┌────────────────────────┐ │
│  │  Shared   │  │  Base OS     │  │  Database / App        │ │
│  │ Endpoints │  │  Linux/Win   │  │  MySQL/PG/MSSQL/Spring │ │
│  │ + Labels  │  │  Metrics+Logs│  │  Metrics + Logs + OTel │ │
│  └──────────┘  └──────────────┘  └────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
```

## Repository Structure

```
├── modules/
│   ├── shared/                      # Shared by all configurations
│   │   ├── endpoints.alloy          #   Remote write endpoints (Prometheus, Loki)
│   │   ├── labels.alloy             #   Common labels (environment, team, region)
│   │   ├── alloy-health-metrics.alloy #  Alloy self-monitoring metrics
│   │   ├── alloy-health-logs.alloy  #   Alloy self-monitoring logs
│   │   ├── otel-collector.alloy     #   OpenTelemetry OTLP receiver + exporter
│   │   └── env-reference.alloy      #   Environment variable documentation
│   │
│   ├── base/                        # OS-level monitoring (Platform team)
│   │   ├── linux/
│   │   │   ├── node-metrics.alloy   #   CPU, memory, disk, network, filesystem
│   │   │   ├── journal-logs.alloy   #   Systemd journal logs
│   │   │   └── file-logs.alloy      #   /var/log file-based logs
│   │   └── windows/
│   │       ├── windows-metrics.alloy      # Windows host metrics
│   │       └── windows-event-logs.alloy   # Application + System event logs
│   │
│   ├── databases/                   # Database monitoring (DBA team)
│   │   ├── mysql/
│   │   │   ├── mysql-metrics.alloy  #   MySQL server metrics
│   │   │   └── mysql-logs.alloy     #   Error log, slow query log
│   │   ├── postgres/
│   │   │   ├── postgres-metrics.alloy  # PostgreSQL server metrics
│   │   │   └── postgres-logs.alloy     # Server logs
│   │   └── mssql/
│   │       ├── mssql-metrics.alloy  #   SQL Server metrics
│   │       └── mssql-logs.alloy     #   Error logs, event log entries
│   │
│   └── applications/               # Application monitoring (Dev teams)
│       └── springboot/
│           ├── springboot-metrics.alloy  # Actuator/Prometheus metrics
│           └── springboot-logs.alloy     # Application log files
│
├── examples/                        # Ready-to-use composed configs
│   ├── linux-server/                #   Linux OS only
│   ├── linux-server-otel/           #   Linux OS + OTel collector
│   ├── linux-mysql/                 #   Linux + MySQL
│   ├── linux-postgres/              #   Linux + PostgreSQL
│   ├── linux-springboot/            #   Linux + Spring Boot + OTel
│   ├── windows-server/              #   Windows OS + OTel collector
│   └── windows-mssql/               #   Windows + MSSQL
│
└── ansible/                         # Ansible automation
    ├── inventory/                   #   Example inventory
    ├── playbooks/                   #   Per-role deployment playbooks
    └── roles/alloy/                 #   Adapted Grafana Alloy role
```

## Design Principles

### Distributed Responsibility

Each module is owned by the team responsible for that layer:

| Layer | Owner | Modules |
|-------|-------|---------|
| **Shared** | Platform / SRE | `modules/shared/` — endpoints, common labels |
| **Base OS** | Platform / Infra | `modules/base/linux/`, `modules/base/windows/` |
| **Databases** | DBA | `modules/databases/mysql/`, `postgres/`, `mssql/` |
| **Applications** | Dev teams | `modules/applications/springboot/` |

### Composability

Each example in `examples/` contains pre-assembled `.alloy` files ready to copy into Alloy's config directory. Just pick the example that matches your server role, copy the `.alloy` files, set environment variables, and start Alloy.

**Linux:**
```bash
sudo cp examples/linux-mysql/*.alloy /etc/alloy/
sudo systemctl restart alloy
```

**Windows:**
```powershell
Copy-Item examples\windows-mssql\*.alloy "C:\Program Files\GrafanaLabs\Alloy\" -Force
Restart-Service "Alloy"
```

### Assembled Config Naming

Each example directory contains one `.alloy` file per concern:

```
/etc/alloy/
├── endpoints.alloy    # Remote write endpoints
├── labels.alloy       # Common labels
├── alloy-health.alloy # Alloy self-monitoring
├── os.alloy           # OS metrics + logs
├── mysql.alloy        # Database metrics + logs (or postgres.alloy, mssql.alloy)
└── springboot.alloy   # Application metrics + logs (optional)
```

## Quick Start

### 1. Prerequisites

- [Grafana Alloy](https://grafana.com/docs/alloy/latest/get-started/install/) installed on the target VM
- A Grafana stack with Prometheus/Mimir and Loki endpoints

### 2. Choose Your Example

| Server Role | Example | OS |
|-------------|---------|-----|
| Basic Linux monitoring | `examples/linux-server/` | Linux |
| Linux + OTel collector | `examples/linux-server-otel/` | Linux |
| Linux + MySQL | `examples/linux-mysql/` | Linux |
| Linux + PostgreSQL | `examples/linux-postgres/` | Linux |
| Linux + Spring Boot + OTel | `examples/linux-springboot/` | Linux |
| Basic Windows + OTel | `examples/windows-server/` | Windows |
| Windows + MSSQL | `examples/windows-mssql/` | Windows |

### 3. Configure Environment Variables

All secrets and endpoint URLs are passed via environment variables — never hardcoded.

See `modules/shared/env-reference.alloy` for the full list, or copy an `env.example` from any example directory.

### 4. Deploy

```bash
# Linux — copy configs and start Alloy
sudo cp examples/<your-example>/*.alloy /etc/alloy/
sudo systemctl restart alloy
```

```powershell
# Windows — copy configs and restart service
Copy-Item examples\<your-example>\*.alloy "C:\Program Files\GrafanaLabs\Alloy\" -Force
Restart-Service "Alloy"
```

### 5. Deploy with Ansible (optional)

The `ansible/` directory contains a role and playbooks for automated deployment to Linux and Windows VMs:

```bash
# Install dependencies
pip install ansible pywinrm
ansible-galaxy collection install ansible.utils ansible.posix ansible.windows community.windows

# Deploy to Linux
ansible-playbook -i inventory/hosts.yml ansible/playbooks/linux-server.yml

# Deploy to Linux + MySQL
ansible-playbook -i inventory/hosts.yml ansible/playbooks/linux-mysql.yml

# Deploy to Windows
ansible-playbook -i inventory/hosts.yml ansible/playbooks/windows-server.yml

# Deploy Windows + MSSQL
ansible-playbook -i inventory/hosts.yml ansible/playbooks/windows-mssql.yml
```

See [ansible/README.md](ansible/README.md) for full setup instructions including WinRM configuration.

## Signals Coverage

| Module | Metrics | Logs | Traces |
|--------|---------|------|--------|
| Alloy health | ✅ Self-monitoring metrics | ✅ Internal logs | — |
| Linux base | ✅ Node/host metrics | ✅ Journal + file logs | — |
| Windows base | ✅ Windows host metrics | ✅ Event logs | — |
| OTel Collector | ✅ Host info metrics | ✅ Via OTLP | ✅ Via OTLP |
| MySQL | ✅ Server metrics | ✅ Error + slow query logs | — |
| PostgreSQL | ✅ Server metrics | ✅ Server logs | — |
| MSSQL | ✅ Server metrics | ✅ Error logs + event log | — |
| Spring Boot | ✅ Actuator metrics | ✅ Application logs | ✅ Via OTel Collector |

## Adding a New Module

1. Create a new directory under the appropriate layer in `modules/`
2. Write `.alloy` config files following the Grafana Cloud integration pattern:
   - Use `discovery.relabel` to set `instance = constants.hostname` and `job = "integrations/<name>"`
   - Use `prometheus.relabel` between scrape and `add_common_labels` to drop unwanted metrics
3. Forward metrics to `prometheus.relabel.add_common_labels.receiver`
4. Forward logs to `loki.process.add_common_labels.receiver`
5. Add a `README.md` documenting prerequisites and environment variables
6. Create or update an example in `examples/` to include the new module
7. Update this README's structure tree and signals coverage table
8. Run `make test` to validate all examples

## Contributing

See `.github/copilot-instructions.md` for coding conventions and contribution guidelines.