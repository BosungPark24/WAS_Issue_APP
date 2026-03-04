@echo off
chcp 65001 >nul
echo ========================================
echo WAS 이슈 테스트 애플리케이션 배포 스크립트
echo ========================================
echo.

REM Tomcat 경로 설정 (사용자 환경에 맞게 수정하세요)
set TOMCAT_HOME=C:\apache-tomcat-9.0.xx
set APP_NAME=was-issue-test

REM 현재 스크립트 위치 확인
set SCRIPT_DIR=%~dp0

echo [1/4] 환경 확인...
if not exist "%TOMCAT_HOME%" (
    echo 오류: Tomcat 경로를 찾을 수 없습니다!
    echo TOMCAT_HOME 변수를 수정하세요: %TOMCAT_HOME%
    echo.
    echo 또는 수동으로 다음 명령을 실행하세요:
    echo   xcopy /E /I /Y "%SCRIPT_DIR%" "%TOMCAT_HOME%\webapps\%APP_NAME%\"
    pause
    exit /b 1
)

echo Tomcat 경로: %TOMCAT_HOME%
echo.

echo [2/4] Java 버전 확인...
java -version
if errorlevel 1 (
    echo 오류: Java가 설치되어 있지 않거나 PATH에 없습니다!
    pause
    exit /b 1
)
echo.

echo [3/4] 애플리케이션 배포 중...
if exist "%TOMCAT_HOME%\webapps\%APP_NAME%" (
    echo 기존 배포 삭제 중...
    rmdir /S /Q "%TOMCAT_HOME%\webapps\%APP_NAME%"
)

echo 파일 복사 중...
xcopy /E /I /Y "%SCRIPT_DIR%*" "%TOMCAT_HOME%\webapps\%APP_NAME%\"
if errorlevel 1 (
    echo 오류: 파일 복사 실패!
    pause
    exit /b 1
)
echo 배포 완료!
echo.

echo [4/4] Tomcat 시작...
echo.
echo Tomcat을 시작하려면 다음 명령을 실행하세요:
echo   cd %TOMCAT_HOME%\bin
echo   startup.bat
echo.
echo 또는 브라우저에서 다음 주소로 접속하세요:
echo   http://localhost:8080/%APP_NAME%/
echo.

set /p START_TOMCAT="Tomcat을 지금 시작하시겠습니까? (Y/N): "
if /i "%START_TOMCAT%"=="Y" (
    echo Tomcat 시작 중...
    cd /d "%TOMCAT_HOME%\bin"
    call startup.bat
    echo.
    echo Tomcat이 시작되었습니다!
    echo 브라우저에서 http://localhost:8080/%APP_NAME%/ 로 접속하세요.
) else (
    echo.
    echo 배포가 완료되었습니다.
    echo 수동으로 Tomcat을 시작한 후 접속하세요.
)

echo.
pause
