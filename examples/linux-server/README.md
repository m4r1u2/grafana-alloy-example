# Linux Server

Basic Linux OS monitoring — no databases or applications.

## What This Configures

| Layer | Module | Signals |
|-------|--------|---------|
| OS | Linux base | Node metrics (CPU, memory, disk, network), journal logs, file logs |

## Files

| File | Description |
|------|-------------|
| `endpoints.alloy` | Remote write endpoints (Prometheus, Loki) |
| `labels.alloy` | Common labels (environment, team, region, system, server_class, zone) |
| `alloy-health.alloy` | Alloy self-monitoring metrics and logs |
| `os.alloy` | Linux host metrics + journal + file logs |

## Quick Start

```bash
# 1. Copy example configs to Alloy config directory
sudo mkdir -p /etc/alloy/config.d
sudo cp examples/linux-server/*.alloy /etc/alloy/config.d/

# 2. Set environment variables (or use /etc/alloy/env with systemd EnvironmentFile)
export PROMETHEUS_REMOTE_WRITE_URL="https://prometheus.example.com/api/v1/write"
export LOKI_WRITE_URL="https://loki.example.com/loki/api/v1/push"
export ENVIRONMENT="prod"
export TEAM="infra"
export REGION="eu-west-1"
export SYSTEM=""
export SERVER_CLASS=""
export ZONE=""

# 3. Start Alloy
sudo alloy run /etc/alloy/config.d/ --storage.path=/var/lib/alloy/data
```
