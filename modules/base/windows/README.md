# Windows Base OS Module

Collects host-level metrics and event logs for Windows VMs.
Aligned with Grafana Cloud Windows integration defaults.

## Files

| File | Type | Description |
|------|------|-------------|
| `windows-metrics.alloy` | Metrics | CPU, memory, disk, network, services (via `prometheus.exporter.windows`) |
| `windows-event-logs.alloy` | Logs | Application and System event logs |

## Prerequisites

- Alloy must run as a Windows service with `Local System` or equivalent privileges

## Dependencies

- `modules/shared/endpoints.alloy` — defines `prometheus.remote_write.default` and `loki.write.default`
- `modules/shared/labels.alloy` — defines `prometheus.relabel.add_common_labels` and `loki.process.add_common_labels`

## Alloy Configuration

```powershell
# Point Alloy at a directory containing the shared + windows base modules
alloy.exe run C:\ProgramData\GrafanaAlloy\config.d\
```
