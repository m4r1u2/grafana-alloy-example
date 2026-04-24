# MSSQL Module (Windows)

Collects Microsoft SQL Server metrics and logs on Windows VMs.

## Files

| File | Type | Description |
|------|------|-------------|
| `mssql-metrics.alloy` | Metrics | SQL Server metrics via `prometheus.exporter.mssql` |
| `mssql-logs.alloy` | Logs | SQL Server error log files and Application Event Log entries |

## Prerequisites

- Create a dedicated SQL Server monitoring login:
  ```sql
  CREATE LOGIN [alloy_monitor] WITH PASSWORD = '<password>';
  GRANT VIEW SERVER STATE TO [alloy_monitor];
  GRANT VIEW ANY DEFINITION TO [alloy_monitor];
  ```
- Set `MSSQL_CONNECTION_STRING` environment variable:
  ```
  MSSQL_CONNECTION_STRING=sqlserver://alloy_monitor:<password>@localhost:1433
  ```

## Dependencies

- `modules/shared/endpoints.alloy`
- `modules/shared/labels.alloy`
- Use alongside `modules/base/windows/` for OS-level monitoring
