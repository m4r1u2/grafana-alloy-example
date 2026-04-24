# MySQL Module (Linux)

Collects MySQL metrics and logs on Linux VMs.
Aligned with Grafana Cloud MySQL integration defaults.

## Files

| File | Type | Description |
|------|------|-------------|
| `mysql-metrics.alloy` | Metrics | MySQL server metrics via `prometheus.exporter.mysql` |
| `mysql-logs.alloy` | Logs | Error log collection from `/var/log/mysql/*.log` |

## Prerequisites

- Create a dedicated MySQL monitoring user:
  ```sql
  CREATE USER 'alloy'@'localhost' IDENTIFIED BY '<password>';
  GRANT PROCESS, REPLICATION CLIENT, SELECT ON *.* TO 'alloy'@'localhost';
  FLUSH PRIVILEGES;
  ```
- Set `MYSQL_DSN` environment variable:
  ```
  MYSQL_DSN=alloy:<password>@tcp(localhost:3306)/
  ```
- Enable slow query log in MySQL config if desired:
  ```ini
  [mysqld]
  slow_query_log = 1
  slow_query_log_file = /var/log/mysql/slow.log
  long_query_time = 2
  ```

## Dependencies

- `modules/shared/endpoints.alloy`
- `modules/shared/labels.alloy`
- Use alongside `modules/base/linux/` for OS-level monitoring
