# Linux Base OS Module

Collects host-level metrics and system logs for Linux VMs.

## Files

| File | Type | Description |
|------|------|-------------|
| `node-metrics.alloy` | Metrics | CPU, memory, disk, network, filesystem, load (via `prometheus.exporter.unix`) |
| `journal-logs.alloy` | Logs | Systemd journal logs with unit, level, boot_id, and transport labels |
| `file-logs.alloy` | Logs | Traditional log files from `/var/log/{syslog,messages,*.log}` |

## Prerequisites

- Alloy must run as a user with read access to `/var/log/journal` and `/var/log/*`
- Typically run as `root` or in the `systemd-journal` / `adm` groups

## Dependencies

- `modules/shared/endpoints.alloy` — defines `prometheus.remote_write.default` and `loki.write.default`
- `modules/shared/labels.alloy` — defines `prometheus.relabel.add_common_labels` and `loki.process.add_common_labels`

## Alloy Configuration

```bash
# Point Alloy at a directory containing the shared + linux base modules
sudo alloy run \
  /etc/alloy/config.d/ \
  --storage.path=/var/lib/alloy/data
```
