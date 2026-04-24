# Spring Boot Module

Collects metrics and logs from Spring Boot applications, with optional OpenTelemetry instrumentation for traces.

Works on both **Linux** and **Windows** VMs.

## Files

| File | Type | Description |
|------|------|-------------|
| `springboot-metrics.alloy` | Metrics | Scrapes Prometheus metrics from Actuator endpoint |
| `springboot-logs.alloy` | Logs | Collects application log files (Linux/Windows paths) |

> **Note:** OpenTelemetry (traces, OTel metrics/logs) is handled by the shared `modules/shared/otel-collector.alloy` module, not by a Spring Boot-specific file. Use the `linux-springboot` or `linux-server-otel` example to include OTel support.

## Spring Boot Application Setup

### 1. Add Actuator + Prometheus Metrics

Add to `pom.xml`:
```xml
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-actuator</artifactId>
</dependency>
<dependency>
    <groupId>io.micrometer</groupId>
    <artifactId>micrometer-registry-prometheus</artifactId>
</dependency>
```

Add to `application.yml`:
```yaml
management:
  endpoints:
    web:
      exposure:
        include: health,info,prometheus,metrics
  metrics:
    tags:
      application: ${spring.application.name}
```

### 2. OpenTelemetry Instrumentation (Optional)

Use the **OpenTelemetry Java Agent** for automatic instrumentation (no code changes):

```bash
# Download the agent
curl -L -o opentelemetry-javaagent.jar \
  https://github.com/open-telemetry/opentelemetry-java-instrumentation/releases/latest/download/opentelemetry-javaagent.jar

# Run your app with the agent
java -javaagent:opentelemetry-javaagent.jar \
  -Dotel.service.name=my-springboot-app \
  -Dotel.exporter.otlp.endpoint=http://localhost:4317 \
  -Dotel.exporter.otlp.protocol=grpc \
  -Dotel.traces.exporter=otlp \
  -Dotel.metrics.exporter=otlp \
  -Dotel.logs.exporter=otlp \
  -jar my-app.jar
```

**On Windows** (PowerShell):
```powershell
java -javaagent:opentelemetry-javaagent.jar `
  -Dotel.service.name=my-springboot-app `
  -Dotel.exporter.otlp.endpoint=http://localhost:4317 `
  -Dotel.exporter.otlp.protocol=grpc `
  -Dotel.traces.exporter=otlp `
  -Dotel.metrics.exporter=otlp `
  -Dotel.logs.exporter=otlp `
  -jar my-app.jar
```

**Alternative: SDK-based instrumentation** (requires code changes):

Add to `pom.xml`:
```xml
<dependency>
    <groupId>io.opentelemetry.instrumentation</groupId>
    <artifactId>opentelemetry-spring-boot-starter</artifactId>
</dependency>
```

Add to `application.yml`:
```yaml
otel:
  exporter:
    otlp:
      endpoint: http://localhost:4317
  service:
    name: my-springboot-app
  resource:
    attributes:
      environment: ${ENVIRONMENT:dev}
      team: ${TEAM:unknown}
```

### 3. Structured Logging (Recommended)

For best log parsing, configure structured JSON logging:

```xml
<!-- logback-spring.xml -->
<configuration>
    <appender name="FILE" class="ch.qos.logback.core.rolling.RollingFileAppender">
        <file>/var/log/springboot/${APP_NAME}.log</file>
        <rollingPolicy class="ch.qos.logback.core.rolling.SizeAndTimeBasedRollingPolicy">
            <fileNamePattern>/var/log/springboot/${APP_NAME}-%d{yyyy-MM-dd}.%i.log</fileNamePattern>
            <maxFileSize>100MB</maxFileSize>
            <maxHistory>30</maxHistory>
        </rollingPolicy>
        <encoder class="ch.qos.logback.classic.encoder.PatternLayoutEncoder">
            <pattern>%d{yyyy-MM-dd'T'HH:mm:ss.SSS} %level %pid --- [%thread] %logger : %msg%n</pattern>
        </encoder>
    </appender>
    <root level="INFO">
        <appender-ref ref="FILE" />
    </root>
</configuration>
```

## Environment Variables

| Variable | Required | Description |
|----------|----------|-------------|
| `SERVICE_NAME` | Yes | Service name for labeling (aligns with OTel `service.name`) |
| `TEMPO_OTLP_ENDPOINT` | For OTel | Tempo OTLP gRPC endpoint |
| `TEMPO_USERNAME` | For OTel | Tempo basic auth username |
| `TEMPO_PASSWORD` | For OTel | Tempo basic auth password |

## Dependencies

- `modules/shared/endpoints.alloy`
- `modules/shared/labels.alloy`
- Use alongside `modules/base/linux/` or `modules/base/windows/` for OS-level monitoring
