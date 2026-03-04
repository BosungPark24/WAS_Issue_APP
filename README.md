# WAS 이슈 재현 테스트 애플리케이션

Web/WAS 환경에서 자주 발생하는 이슈를 의도적으로 재현하기 위한 테스트 앱입니다.

## 주의

운영 환경에서 사용하지 마세요.

- 서버 다운/성능 저하/리소스 고갈이 발생할 수 있습니다.
- 반드시 테스트 전용 환경에서만 사용하세요.

## 주요 페이지

- `index.jsp`: 메인 페이지
- `oome.jsp`: OutOfMemoryError 재현
- `connection_pool.jsp`: 커넥션 풀 고갈 재현
- `slow_query.jsp`: 느린 쿼리/타임아웃 재현
- `session_leak.jsp`: 세션 누수 재현
- `thread_pool.jsp`: 스레드 고갈 재현
- `file_handle.jsp`: 파일 핸들 누수 재현
- `cache_leak.jsp`: 캐시 누수 재현
- `permgen_leak.jsp`: Metaspace 누수 재현
- `deadlock.jsp`: 데드락 재현
- `cpu_overload.jsp`: CPU 과부하 재현

## 로컬 실행 (Spring Boot 내장 Tomcat)

```bash
mvn -DskipTests package
java -jar target/bosung-app.war
```

접속:

```text
http://localhost:8080/was-issue-test/
```

## WebLogic 배포 자동화

`deploy/` 폴더의 스크립트를 사용합니다.

- `deploy/deploy.ps1`: 전체 배포 파이프라인 실행
- `deploy/README.md`: 배포 사용법
- `deploy/GITHUB_ACTIONS.md`: GitHub Actions CI/CD 설정

## Docker (테스트 용도)

```bash
docker compose up --build -d
```

자세한 내용:

- `DOCKER.md`

