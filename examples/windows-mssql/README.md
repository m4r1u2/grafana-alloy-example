# Windows VM with MSSQL

## What This Configures

| Layer | Module | Signals |
|-------|--------|---------|
| OS | Windows base | Windows metrics, Application/System event logs |
| Database | MSSQL | SQL Server metrics, error logs, application event log entries |

## Files

| File | Description |
|------|-------------|
| `endpoints.alloy` | Remote write endpoints (Prometheus, Loki) |
| `labels.alloy` | Common labels (environment, team, region, system, server_class, zone) |
| `alloy-health.alloy` | Alloy self-monitoring metrics and logs |
| `os.alloy` | Windows host metrics + event logs |
| `mssql.alloy` | MSSQL metrics + error logs + event log entries |

## Quick Start

```powershell
# 1. Copy example configs to Alloy config directory
New-Item -ItemType Directory -Force -Path "C:\ProgramData\GrafanaAlloy\config.d"
Copy-Item examples\windows-mssql\*.alloy "C:\ProgramData\GrafanaAlloy\config.d\" -Force

# 2. Set environment variables (System-level for the Alloy service)
[System.Environment]::SetEnvironmentVariable("PROMETHEUS_REMOTE_WRITE_URL", "https://prometheus.example.com/api/v1/write", "Machine")
[System.Environment]::SetEnvironmentVariable("PROMETHEUS_USERNAME", "user", "Machine")
[System.Environment]::SetEnvironmentVariable("PROMETHEUS_PASSWORD", "pass", "Machine")
[System.Environment]::SetEnvironmentVariable("LOKI_WRITE_URL", "https://loki.example.com/loki/api/v1/push", "Machine")
[System.Environment]::SetEnvironmentVariable("LOKI_USERNAME", "user", "Machine")
[System.Environment]::SetEnvironmentVariable("LOKI_PASSWORD", "pass", "Machine")
[System.Environment]::SetEnvironmentVariable("ENVIRONMENT", "prod", "Machine")
[System.Environment]::SetEnvironmentVariable("TEAM", "dba", "Machine")
[System.Environment]::SetEnvironmentVariable("REGION", "eu-west-1", "Machine")
[System.Environment]::SetEnvironmentVariable("SYSTEM", "", "Machine")
[System.Environment]::SetEnvironmentVariable("SERVER_CLASS", "", "Machine")
[System.Environment]::SetEnvironmentVariable("ZONE", "", "Machine")
[System.Environment]::SetEnvironmentVariable("MSSQL_CONNECTION_STRING", "sqlserver://alloy_monitor:password@localhost:1433", "Machine")

# 3. Restart Alloy service
Restart-Service "Grafana Alloy"
```
