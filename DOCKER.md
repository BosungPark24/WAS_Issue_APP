# Docker Usage Guide

## Goal
Use Docker primarily for repeatable test/repro environments, not as the first production deployment target.

## Build and run
```bash
docker compose up --build -d
```

Access:
```text
http://localhost:8080/was-issue-test/
```

Stop:
```bash
docker compose down
```

## Recommended usage pattern
1. Local regression/reproduction runs before WebLogic deployment.
2. Team-shared environment with identical JDK/Tomcat behavior.
3. CI smoke test step (`docker compose up`, health check, `down`).

## Notes
- This container runs Spring Boot embedded Tomcat (`java -jar target war`).
- Production on `10.20.210.239` should continue to use WebLogic deployment scripts in `deploy/`.
