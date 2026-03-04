<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>WAS 이슈 재현 테스트 애플리케이션</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 20px;
            background-color: #f5f5f5;
        }
        .container {
            max-width: 1200px;
            margin: 0 auto;
            background: white;
            padding: 20px;
            border-radius: 8px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }
        h1 {
            color: #333;
            border-bottom: 3px solid #4CAF50;
            padding-bottom: 10px;
        }
        .warning {
            background-color: #fff3cd;
            border: 1px solid #ffc107;
            padding: 15px;
            border-radius: 4px;
            margin: 20px 0;
        }
        .test-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
            gap: 15px;
            margin-top: 20px;
        }
        .test-card {
            border: 1px solid #ddd;
            border-radius: 4px;
            padding: 15px;
            background: #f9f9f9;
            transition: all 0.3s;
        }
        .test-card:hover {
            box-shadow: 0 4px 8px rgba(0,0,0,0.1);
            transform: translateY(-2px);
        }
        .test-card h3 {
            margin-top: 0;
            color: #d32f2f;
        }
        .test-card p {
            color: #666;
            font-size: 14px;
        }
        .btn {
            display: inline-block;
            padding: 10px 20px;
            background-color: #d32f2f;
            color: white;
            text-decoration: none;
            border-radius: 4px;
            margin-top: 10px;
            transition: background-color 0.3s;
        }
        .btn:hover {
            background-color: #b71c1c;
        }
        .info {
            background-color: #e3f2fd;
            border-left: 4px solid #2196F3;
            padding: 10px;
            margin: 10px 0;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>🔧 WAS 이슈 재현 테스트 애플리케이션</h1>
        
        <div class="warning">
            <strong>⚠️ 경고:</strong> 이 애플리케이션은 WAS에서 발생하는 다양한 이슈를 의도적으로 재현합니다. 
            운영 환경에서는 절대 사용하지 마세요. 테스트 환경에서만 사용하시기 바랍니다.
        </div>
        
        <div class="info" style="border-left-color:#4CAF50;">
            <strong>REDEPLOY CHECK:</strong> DEPLOY_CHECK_20260304_02
        </div>

        <div class="info">
            <strong>JDK 버전:</strong> <%= System.getProperty("java.version") %><br>
            <strong>서버 정보:</strong> <%= application.getServerInfo() %><br>
            <strong>현재 메모리 사용량:</strong> 
            <% 
                Runtime runtime = Runtime.getRuntime();
                long totalMemory = runtime.totalMemory();
                long freeMemory = runtime.freeMemory();
                long usedMemory = totalMemory - freeMemory;
                long maxMemory = runtime.maxMemory();
            %>
            <%= String.format("%.2f MB / %.2f MB (Max: %.2f MB)", 
                usedMemory / 1024.0 / 1024.0, 
                totalMemory / 1024.0 / 1024.0,
                maxMemory / 1024.0 / 1024.0) %>
        </div>
        
        <div style="text-align: center; margin: 20px 0;">
            <a href="guide.jsp" class="btn" style="background-color: #4CAF50; font-size: 16px; padding: 12px 30px;">
                📚 테스트 가이드 보기
            </a>
        </div>
        
        <div class="test-grid">
            <div class="test-card">
                <h3>1. OutOfMemoryError (OOME)</h3>
                <p>힙 메모리를 고의로 소진시켜 OOME를 발생시킵니다.</p>
                <a href="oome.jsp" class="btn">테스트 실행</a>
            </div>
            
            <div class="test-card">
                <h3>2. 커넥션 풀 고갈</h3>
                <p>데이터베이스 커넥션을 최대치까지 사용하여 풀 고갈을 재현합니다.</p>
                <a href="connection_pool.jsp" class="btn">테스트 실행</a>
            </div>
            
            <div class="test-card">
                <h3>3. 느린 쿼리</h3>
                <p>장시간 실행되는 쿼리를 수행하여 타임아웃을 재현합니다.</p>
                <a href="slow_query.jsp" class="btn">테스트 실행</a>
            </div>
            
            <div class="test-card">
                <h3>4. 세션 누수</h3>
                <p>세션에 대용량 데이터를 저장하여 세션 누수를 재현합니다.</p>
                <a href="session_leak.jsp" class="btn">테스트 실행</a>
            </div>
            
            <div class="test-card">
                <h3>5. 스레드 풀 고갈</h3>
                <p>대량의 스레드를 생성하여 스레드 풀 고갈을 재현합니다.</p>
                <a href="thread_pool.jsp" class="btn">테스트 실행</a>
            </div>
            
            <div class="test-card">
                <h3>6. 파일 핸들러 누수</h3>
                <p>파일 핸들을 열고 닫지 않아 파일 핸들러 누수를 재현합니다.</p>
                <a href="file_handle.jsp" class="btn">테스트 실행</a>
            </div>
            
            <div class="test-card">
                <h3>7. 캐시 누수</h3>
                <p>정적 캐시에 무한정 데이터를 추가하여 메모리 누수를 재현합니다.</p>
                <a href="cache_leak.jsp" class="btn">테스트 실행</a>
            </div>
            
            <div class="test-card">
                <h3>8. PermGen/Metaspace 누수</h3>
                <p>동적 클래스 로딩을 통한 PermGen/Metaspace 누수를 재현합니다.</p>
                <a href="permgen_leak.jsp" class="btn">테스트 실행</a>
            </div>
            
            <div class="test-card">
                <h3>9. 데드락 시뮬레이션</h3>
                <p>여러 스레드가 서로의 리소스를 기다리는 데드락을 재현합니다.</p>
                <a href="deadlock.jsp" class="btn">테스트 실행</a>
            </div>
            
            <div class="test-card">
                <h3>10. CPU 과부하</h3>
                <p>무한 루프를 통한 CPU 100% 사용을 재현합니다.</p>
                <a href="cpu_overload.jsp" class="btn">테스트 실행</a>
            </div>
            
            <div class="test-card">
                <h3>11. 클러스터링 테스트</h3>
                <p>클러스터 환경에서 세션 어피니티, WLCookie, 세션 복제를 확인합니다.</p>
                <a href="clustering.jsp" class="btn">테스트 실행</a>
            </div>
            
            <div class="test-card">
                <h3>12. DataSource 연동 확인</h3>
                <p>JNDI를 통한 DataSource 연결 및 커넥션 정보를 확인합니다.</p>
                <a href="datasource.jsp" class="btn">테스트 실행</a>
            </div>
        </div>
    </div>
</body>
</html>
