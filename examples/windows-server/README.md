# Windows Server

Basic Windows OS monitoring — no databases or applications.

## What This Configures

| Layer | Module | Signals |
|-------|--------|---------|
| OS | Windows base | Windows metrics (CPU, memory, disk, network), event logs (Application, System) |

## Files

| File | Description |
|------|-------------|
| `endpoints.alloy` | Remote write endpoints (Prometheus, Loki) |
| `labels.alloy` | Common labels (environment, team, region, system, server_class, zone) |
| `alloy-health.alloy` | Alloy self-monitoring metrics and logs |
| `otel-collector.alloy` | OpenTelemetry OTLP receiver + Grafana Cloud exporter |
| `os.alloy` | Windows host metrics + event logs |

## Quick Start

```powershell
# 1. Copy example configs to Alloy config directory
New-Item -ItemType Directory -Force -Path "C:\ProgramData\GrafanaAlloy\config.d"
Copy-Item examples\windows-server\*.alloy "C:\ProgramData\GrafanaAlloy\config.d\" -Force

# 2. Set environment variables
[System.Environment]::SetEnvironmentVariable("PROMETHEUS_REMOTE_WRITE_URL", "https://prometheus.example.com/api/v1/write", "Machine")
[System.Environment]::SetEnvironmentVariable("LOKI_WRITE_URL", "https://loki.example.com/loki/api/v1/push", "Machine")
[System.Environment]::SetEnvironmentVariable("ENVIRONMENT", "prod", "Machine")
[System.Environment]::SetEnvironmentVariable("TEAM", "infra", "Machine")
[System.Environment]::SetEnvironmentVariable("REGION", "eu-west-1", "Machine")
[System.Environment]::SetEnvironmentVariable("SYSTEM", "", "Machine")
[System.Environment]::SetEnvironmentVariable("SERVER_CLASS", "", "Machine")
[System.Environment]::SetEnvironmentVariable("ZONE", "", "Machine")

# 3. Restart Alloy service
Restart-Service "Grafana Alloy"
```
