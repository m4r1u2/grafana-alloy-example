# PostgreSQL Module (Linux)

Collects PostgreSQL metrics and logs on Linux VMs.

## Files

| File | Type | Description |
|------|------|-------------|
| `postgres-metrics.alloy` | Metrics | PostgreSQL server metrics via `prometheus.exporter.postgres` |
| `postgres-logs.alloy` | Logs | Server log collection from standard log locations |

## Prerequisites

- Create a dedicated PostgreSQL monitoring user:
  ```sql
  CREATE USER alloy WITH PASSWORD '<password>';
  GRANT pg_monitor TO alloy;
  ```
- Set `POSTGRES_DSN` environment variable:
  ```
  POSTGRES_DSN=postgresql://alloy:<password>@localhost:5432/postgres?sslmode=disable
  ```
- Ensure `log_destination = 'stderr'` and `logging_collector = on` in `postgresql.conf`

## Dependencies

- `modules/shared/endpoints.alloy`
- `modules/shared/labels.alloy`
- Use alongside `modules/base/linux/` for OS-level monitoring
