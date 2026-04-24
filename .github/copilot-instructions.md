# Copilot Instructions for grafana-alloy-example

## Repository Purpose

This repo contains modular Grafana Alloy configuration examples for classic VMs (not Kubernetes). Configs are split by responsibility layer (OS, database, application) so different teams can own their modules independently.

## Repository Structure

```
modules/shared/          → Shared endpoints, labels, alloy health, OTel collector
modules/base/linux/      → Linux OS metrics and logs
modules/base/windows/    → Windows OS metrics and event logs
modules/databases/mysql/  → MySQL metrics and logs (Linux)
modules/databases/postgres/ → PostgreSQL metrics and logs (Linux)
modules/databases/mssql/  → MSSQL metrics and logs (Windows)
modules/applications/springboot/ → Spring Boot metrics and logs
examples/                → Pre-assembled ready-to-use config directories
```

## Configuration Language

All `.alloy` files use the **Grafana Alloy River syntax** (HCL-like). Key conventions:

- **Components** are declared as `type.name "label" { ... }` (e.g., `prometheus.scrape "integrations_node_exporter"`)
- **References** use dot notation: `prometheus.exporter.unix.integrations_node_exporter.targets`
- **Environment variables** are accessed via `sys.env("VAR_NAME")`
- **Strings** use double quotes. **Multi-line** uses heredoc: `<<-EOF ... EOF`
- **Instance labels** always use `constants.hostname` (never hardcoded hostnames)

## Data Flow Pattern

All modules follow the Grafana Cloud integration pattern:

```
Metrics: exporter → discovery.relabel (instance + job) → prometheus.scrape → prometheus.relabel (filtering) → prometheus.relabel.add_common_labels → prometheus.remote_write.default
Logs:    source → loki.relabel (instance + job) → loki.process.add_common_labels → loki.write.default
Traces:  otelcol.receiver.otlp → otelcol.processor.resourcedetection → otelcol.processor.transform (cleanup + common labels) → otelcol.processor.batch → otelcol.exporter.otlphttp (Grafana Cloud)
```

When creating new modules:
- Use `discovery.relabel` to set `instance = constants.hostname` and `job = "integrations/<name>"`
- Use `prometheus.relabel` between scrape and `add_common_labels` to drop unwanted metrics
- Forward metrics to `prometheus.relabel.add_common_labels.receiver`
- Forward logs to `loki.process.add_common_labels.receiver`
- Add `instance` and `job` labels to all log source targets
- Never write directly to `prometheus.remote_write.default` or `loki.write.default` — always go through the label enrichment layer

## Conventions for New Modules

### File Organization
- One `.alloy` file per concern (metrics, logs, traces)
- Each module directory must have a `README.md`
- Use clear, descriptive component labels following Grafana Cloud convention (e.g., `"integrations_mysqld_exporter"` not `"default"`)

### Naming
- File names: `<technology>-<signal>.alloy` (e.g., `mysql-metrics.alloy`, `postgres-logs.alloy`)
- Component labels: `integrations_<technology>` for metrics, `logs_integrations_<technology>` for logs
- Job labels: `integrations/<technology>` (e.g., `integrations/node_exporter`, `integrations/mysql`)
- Module directories: lowercase, matching the technology name

### Comments
- Every `.alloy` file starts with a header comment block explaining what it does
- Include a `Responsibility:` line indicating the owning team
- Document which environment variables are required

### Environment Variables
- All secrets (passwords, tokens) MUST use `sys.env("VAR_NAME")` — never hardcode
- All endpoint URLs should be environment variables
- Document new env vars in `modules/shared/env-reference.alloy`

### Scrape Intervals
- OS-level metrics: `60s`
- Database metrics: `60s`
- Application metrics: `30s`
- Adjust only with justification in comments

## Assembled Config Naming Convention

Each example in `examples/` contains pre-assembled `.alloy` files, one per concern:

| Assembled file | Source modules |
|----------------|----------------|
| `endpoints.alloy` | `modules/shared/endpoints.alloy` |
| `labels.alloy` | `modules/shared/labels.alloy` |
| `alloy-health.alloy` | `modules/shared/alloy-health-metrics.alloy` + `alloy-health-logs.alloy` |
| `otel-collector.alloy` | `modules/shared/otel-collector.alloy` |
| `os.alloy` | All files from `modules/base/linux/` or `modules/base/windows/` |
| `mysql.alloy` | All files from `modules/databases/mysql/` |
| `postgres.alloy` | All files from `modules/databases/postgres/` |
| `mssql.alloy` | All files from `modules/databases/mssql/` |
| `springboot.alloy` | `modules/applications/springboot/springboot-metrics.alloy` + `springboot-logs.alloy` |

When adding a new technology module, name the assembled file after the technology (e.g., `redis.alloy`, `nginx.alloy`).

## Examples

Every example in `examples/` must have:
- Pre-assembled `.alloy` files ready to copy into Alloy's config directory
- `README.md` with a files table, quick start guide, and environment variable list
- `env.example` (Linux examples) with template environment variables

## Keeping Examples in Sync

**IMPORTANT**: The `examples/` directory contains pre-assembled configs derived from the source modules in `modules/`. When a module changes, all examples that include it MUST be updated to stay in sync.

### When modifying a module:

1. Make the change in the source file under `modules/`
2. Identify which examples include that module (see the source mapping table above)
3. Re-assemble every affected example file by concatenating the source modules:
   - `endpoints.alloy` = copy of `modules/shared/endpoints.alloy`
   - `labels.alloy` = copy of `modules/shared/labels.alloy`
   - `alloy-health.alloy` = concatenation of `modules/shared/alloy-health-metrics.alloy` + `alloy-health-logs.alloy`
   - `otel-collector.alloy` = copy of `modules/shared/otel-collector.alloy`
   - `os.alloy` = concatenation of all files in `modules/base/linux/` (or `windows/`)
   - `<tech>.alloy` = concatenation of all files in that technology's module directory
4. Each example file must have a header comment listing its source modules

### When adding a new module:

1. Create source files in `modules/<layer>/<technology>/`
2. Create or update example directories that should include the new module
3. Add the new `<technology>.alloy` assembled file to each relevant example
4. Update the example's `README.md` with the new file in the files table
5. If it's a new example directory, create its own `README.md` and `env.example`

### When adding a new example:

1. Create a new directory under `examples/` named `<os>-<tech1>-<tech2>`
2. Assemble `.alloy` files from the relevant modules (always include `endpoints.alloy` and `labels.alloy`)
3. Write a `README.md` with: What This Configures table, Files table, Quick Start
4. Add `env.example` for Linux examples

## Validation

**IMPORTANT**: Always run `make test` after any changes to `.alloy` files. This runs:
- `alloy validate` on each example directory
- `alloy fmt -t` to check formatting on all `.alloy` files

```bash
make test       # Run all checks (validate + fmt-check)
make validate   # Validate example configs only
make fmt-check  # Check formatting only
make fmt        # Auto-format all .alloy files
```

If formatting fails, run `make fmt` first, then re-run `make test`.

## Keeping Documentation Current

When adding or modifying modules:
1. Update the module's own `README.md`
2. Update the root `README.md`:
   - Repository structure tree
   - Signals coverage table
   - Example table (if new examples added)
3. Update `modules/shared/env-reference.alloy` with any new environment variables
4. Update this file (`copilot-instructions.md`) if new patterns or conventions are introduced

## Grafana Cloud Alignment

All module configurations are aligned with the **default Grafana Cloud integration snippets**. When writing new modules:
- Follow the component naming from [Grafana Cloud integration reference](https://grafana.com/docs/grafana-cloud/monitor-infrastructure/integrations/integration-reference/)
- Use `discovery.relabel` with `instance = constants.hostname` and `job = "integrations/<name>"`
- Drop unwanted metrics via `prometheus.relabel` (e.g., `node_scrape_collector_.+`, `HarddiskVolume.*`)
- Use `locale = 1033`, `poll_interval = "0s"`, and `use_incoming_timestamp = true` for Windows event logs

## Supported Platforms

Currently focused on **classic VMs** (not Kubernetes):
- **Linux**: Ubuntu, RHEL, CentOS, Debian
- **Windows**: Windows Server 2016+

## Technology Reference

- [Grafana Alloy docs](https://grafana.com/docs/alloy/latest/)
- [Alloy component reference](https://grafana.com/docs/alloy/latest/reference/components/)
- [River syntax](https://grafana.com/docs/alloy/latest/concepts/configuration-syntax/)
- [OpenTelemetry Java Agent](https://opentelemetry.io/docs/languages/java/automatic/)
- [Grafana Cloud integrations](https://grafana.com/docs/grafana-cloud/monitor-infrastructure/integrations/integration-reference/)
