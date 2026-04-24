# Linux + PostgreSQL

Linux OS monitoring with PostgreSQL metrics and logs — no application layer.

## What This Configures

| Layer | Module | Signals |
|-------|--------|---------|
| OS | Linux base | Node metrics (CPU, memory, disk, network), journal logs, file logs |
| Database | PostgreSQL | Server metrics (connections, transactions, locks), server logs |

## Files

| File | Description |
|------|-------------|
| `endpoints.alloy` | Remote write endpoints (Prometheus, Loki) |
| `labels.alloy` | Common labels (environment, team, region, system, server_class, zone) |
| `alloy-health.alloy` | Alloy self-monitoring metrics and logs |
| `os.alloy` | Linux host metrics + journal + file logs |
| `postgres.alloy` | PostgreSQL metrics + log collection |

## Quick Start

```bash
# 1. Copy example configs to Alloy config directory
sudo mkdir -p /etc/alloy/config.d
sudo cp examples/linux-postgres/*.alloy /etc/alloy/config.d/

# 2. Set environment variables (or use /etc/alloy/env with systemd EnvironmentFile)
export PROMETHEUS_REMOTE_WRITE_URL="https://prometheus.example.com/api/v1/write"
export LOKI_WRITE_URL="https://loki.example.com/loki/api/v1/push"
export POSTGRES_DSN="postgresql://alloy:password@localhost:5432/postgres?sslmode=disable"
export ENVIRONMENT="prod"
export TEAM="infra"
```

## PostgreSQL Prerequisites

Create a monitoring user with the `pg_monitor` role:

```sql
CREATE USER alloy WITH PASSWORD '<password>';
GRANT pg_monitor TO alloy;
```

## Environment Variables

See `env.example` for the full list. Key database-specific variables:

| Variable | Description |
|----------|-------------|
| `POSTGRES_DSN` | PostgreSQL connection string (e.g., `postgresql://alloy:password@localhost:5432/postgres?sslmode=disable`) |
