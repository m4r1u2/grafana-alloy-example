# Linux + Spring Boot

Linux OS monitoring with Spring Boot application metrics, logs, and OpenTelemetry traces.

## What This Configures

| Layer | Module | Signals |
|-------|--------|---------|
| OS | Linux base | Node metrics (CPU, memory, disk, network), journal logs, file logs |
| OTel | OTel Collector | OTLP receiver (gRPC + HTTP) → Grafana Cloud |
| Application | Spring Boot | Actuator/Prometheus metrics, application logs |
| Self | Alloy health | Alloy self-monitoring metrics and internal logs |

## Files

| File | Description |
|------|-------------|
| `endpoints.alloy` | Remote write endpoints (Prometheus, Loki) |
| `labels.alloy` | Common labels (environment, team, region, system, server_class, zone) |
| `alloy-health.alloy` | Alloy self-monitoring metrics and logs |
| `otel-collector.alloy` | OpenTelemetry OTLP receiver + Grafana Cloud exporter |
| `os.alloy` | Linux host metrics + journal + file logs |
| `springboot.alloy` | Spring Boot metrics + log collection |

## Quick Start

```bash
# 1. Copy example configs to Alloy config directory
sudo cp examples/linux-springboot/*.alloy /etc/alloy/

# 2. Set environment variables (or use /etc/default/alloy)
export PROMETHEUS_REMOTE_WRITE_URL="https://prometheus.example.com/api/v1/write"
export PROMETHEUS_USERNAME="user"
export PROMETHEUS_PASSWORD="pass"
export LOKI_WRITE_URL="https://loki.example.com/loki/api/v1/push"
export LOKI_USERNAME="user"
export LOKI_PASSWORD="pass"
export OTLP_ENDPOINT="https://otlp-gateway-prod-eu-west-0.grafana.net/otlp"
export OTLP_USERNAME="123456"
export OTLP_PASSWORD="glc_xxxxxxxxxxxxx"
export ENVIRONMENT="prod"
export TEAM="dev"

# 3. Restart Alloy
sudo systemctl restart alloy
```

## Spring Boot Prerequisites

See [modules/applications/springboot/README.md](../../modules/applications/springboot/README.md) for full setup:
- Add `spring-boot-starter-actuator` + `micrometer-registry-prometheus`
- Use the OpenTelemetry Java Agent for automatic trace instrumentation

## Environment Variables

See `env.example` for the full list.

| Variable | Description |
|----------|-------------|
| `OTLP_ENDPOINT` | Grafana Cloud OTLP gateway URL |
| `OTLP_USERNAME` | Grafana Cloud instance ID |
| `OTLP_PASSWORD` | Grafana Cloud API token |
| `SERVICE_NAME` | Application service name for log correlation |
