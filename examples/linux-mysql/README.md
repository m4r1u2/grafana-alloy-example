# Linux + MySQL

Linux OS monitoring with MySQL metrics and logs — no application layer.

## What This Configures

| Layer | Module | Signals |
|-------|--------|---------|
| OS | Linux base | Node metrics (CPU, memory, disk, network), journal logs, file logs |
| Database | MySQL | Server metrics (connections, queries, buffer pool), error + slow query logs |

## Files

| File | Description |
|------|-------------|
| `endpoints.alloy` | Remote write endpoints (Prometheus, Loki) |
| `labels.alloy` | Common labels (environment, team, region, system, server_class, zone) |
| `alloy-health.alloy` | Alloy self-monitoring metrics and logs |
| `os.alloy` | Linux host metrics + journal + file logs |
| `mysql.alloy` | MySQL metrics + log collection |

## Quick Start

```bash
# 1. Copy example configs to Alloy config directory
sudo mkdir -p /etc/alloy/config.d
sudo cp examples/linux-mysql/*.alloy /etc/alloy/config.d/

# 2. Set environment variables (or use /etc/alloy/env with systemd EnvironmentFile)
export PROMETHEUS_REMOTE_WRITE_URL="https://prometheus.example.com/api/v1/write"
export LOKI_WRITE_URL="https://loki.example.com/loki/api/v1/push"
export MYSQL_DSN="alloy:password@tcp(localhost:3306)/"
export ENVIRONMENT="prod"
export TEAM="infra"
```

## MySQL Prerequisites

Create a monitoring user with minimal privileges:

```sql
CREATE USER 'alloy'@'localhost' IDENTIFIED BY '<password>';
GRANT PROCESS, REPLICATION CLIENT, SELECT ON *.* TO 'alloy'@'localhost';
FLUSH PRIVILEGES;
```

## Environment Variables

See `env.example` for the full list. Key database-specific variables:

| Variable | Description |
|----------|-------------|
| `MYSQL_DSN` | MySQL data source name (e.g., `alloy:password@tcp(localhost:3306)/`) |
