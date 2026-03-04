# WAS 이슈 테스트 애플리케이션 실행 가이드

## 🚀 빠른 시작 (Tomcat 기준)

### 방법 1: Tomcat 디렉토리에 직접 배포 (가장 간단)

1. **Tomcat 다운로드 및 설치**
   - Apache Tomcat 8.x 또는 9.x 다운로드
   - 압축 해제 (예: `C:\apache-tomcat-9.0.xx`)

2. **프로젝트 배포**
   ```powershell
   # 현재 프로젝트 디렉토리를 Tomcat의 webapps 폴더에 복사
   # 예: C:\apache-tomcat-9.0.xx\webapps\was-issue-test\
   ```

3. **Tomcat 시작**
   ```powershell
   # Tomcat bin 디렉토리로 이동
   cd C:\apache-tomcat-9.0.xx\bin
   
   # 시작
   .\startup.bat
   ```

4. **브라우저에서 접속**
   ```
   http://localhost:8080/was-issue-test/
   ```

### 방법 2: WAR 파일로 배포

1. **WAR 파일 생성**
   ```powershell
   # 프로젝트 루트 디렉토리에서 실행
   jar cvf was-issue-test.war *
   ```

2. **WAR 파일 배포**
   - 생성된 `was-issue-test.war` 파일을 Tomcat의 `webapps` 폴더에 복사
   - Tomcat이 자동으로 압축 해제 및 배포

3. **Tomcat 시작 및 접속**
   - 위와 동일

---

## 📦 다른 WAS 사용 시

### WebLogic

1. **도메인 생성** (또는 기존 도메인 사용)
2. **Admin Console 접속**
3. **Deployments → Install** 선택
4. **프로젝트 디렉토리 또는 WAR 파일 선택**
5. **배포 완료 후 접속**

### JBoss/WildFly

1. **Standalone 모드로 시작**
   ```powershell
   .\standalone.bat
   ```

2. **배포**
   - 프로젝트를 `standalone/deployments/` 폴더에 복사
   - 또는 WAR 파일을 해당 폴더에 복사

3. **접속**
   ```
   http://localhost:8080/was-issue-test/
   ```

### JEUS

1. **JEUS 서버 시작**
2. **WebAdmin 또는 jeusadmin 사용**
3. **애플리케이션 배포**
4. **접속**

---

## 🔧 상세 설정

### 포트 변경 (Tomcat)

`conf/server.xml` 파일 수정:
```xml
<Connector port="8080" protocol="HTTP/1.1"
           connectionTimeout="20000"
           redirectPort="8443" />
```
포트를 원하는 번호로 변경 (예: 8081)

### 컨텍스트 경로 변경

`WEB-INF/web.xml`에 다음 추가:
```xml
<context-param>
    <param-name>contextPath</param-name>
    <param-value>/was-issue-test</param-value>
</context-param>
```

또는 Tomcat의 경우 `conf/server.xml`에 추가:
```xml
<Context path="/was-issue-test" docBase="C:\path\to\BOSUNG_APP" />
```

---

## ✅ 실행 확인

1. **Tomcat 로그 확인**
   ```
   C:\apache-tomcat-9.0.xx\logs\catalina.out
   ```
   또는
   ```
   C:\apache-tomcat-9.0.xx\logs\localhost.YYYY-MM-DD.log
   ```

2. **정상 배포 확인**
   - 로그에 "Deployment of web application ... has finished" 메시지 확인
   - 에러가 없으면 정상

3. **브라우저 접속**
   ```
   http://localhost:8080/was-issue-test/
   ```
   또는
   ```
   http://localhost:8080/was-issue-test/index.jsp
   ```

---

## 🛠️ 문제 해결

### 404 에러
- 컨텍스트 경로 확인
- `webapps` 폴더에 제대로 배포되었는지 확인
- Tomcat 재시작

### 500 에러 (JSP 컴파일 에러)
- JDK 버전 확인 (Java 8 이상 필요)
- `JAVA_HOME` 환경 변수 설정 확인
- Tomcat의 `conf/web.xml`에서 JSP 컴파일러 설정 확인

### 포트 충돌
- 다른 포트 사용
- 또는 사용 중인 프로세스 종료
  ```powershell
  # 8080 포트 사용 중인 프로세스 확인
  netstat -ano | findstr :8080
  # PID 확인 후 종료
  taskkill /PID <PID번호> /F
  ```

### 권한 문제
- 관리자 권한으로 실행
- 또는 Tomcat 설치 경로의 권한 확인

---

## 📝 빠른 테스트 체크리스트

- [ ] Java 설치 확인: `java -version` (Java 8 이상)
- [ ] Tomcat 다운로드 및 설치
- [ ] 프로젝트를 `webapps` 폴더에 배포
- [ ] Tomcat 시작 (`startup.bat`)
- [ ] 브라우저에서 `http://localhost:8080/was-issue-test/` 접속
- [ ] 메인 페이지가 정상적으로 표시되는지 확인

---

## 💡 팁

1. **개발 중 빠른 재배포**
   - JSP 파일 수정 시 Tomcat이 자동으로 재컴파일
   - `webapps` 폴더의 애플리케이션을 삭제하고 다시 복사하면 재배포

2. **로그 실시간 확인**
   ```powershell
   # PowerShell에서
   Get-Content C:\apache-tomcat-9.0.xx\logs\catalina.out -Wait -Tail 50
   ```

3. **Tomcat 중지**
   ```powershell
   .\shutdown.bat
   ```

---

## ⚠️ 주의사항

- **운영 환경에서 절대 사용하지 마세요!**
- 테스트 전 서버 상태를 확인하세요
- 테스트 후 생성된 리소스를 정리하거나 서버를 재시작하세요
