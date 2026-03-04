<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>테스트 가이드</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; background-color: #f5f5f5; }
        .container { max-width: 1200px; margin: 0 auto; background: white; padding: 20px; border-radius: 8px; }
        h1 { color: #333; border-bottom: 3px solid #4CAF50; padding-bottom: 10px; }
        h2 { color: #2196F3; margin-top: 30px; }
        h3 { color: #666; margin-top: 20px; }
        .guide-section { margin: 30px 0; padding: 20px; background-color: #f9f9f9; border-radius: 4px; border-left: 4px solid #2196F3; }
        .test-item { margin: 20px 0; padding: 15px; background: white; border-radius: 4px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
        .test-item h4 { margin-top: 0; color: #d32f2f; }
        .step { margin: 10px 0; padding: 10px; background-color: #e3f2fd; border-radius: 4px; }
        .warning-box { background-color: #fff3cd; border-left: 4px solid #ffc107; padding: 15px; margin: 15px 0; border-radius: 4px; }
        .info-box { background-color: #e3f2fd; border-left: 4px solid #2196F3; padding: 15px; margin: 15px 0; border-radius: 4px; }
        .success-box { background-color: #e8f5e9; border-left: 4px solid #4CAF50; padding: 15px; margin: 15px 0; border-radius: 4px; }
        .code { background-color: #f5f5f5; padding: 10px; border-radius: 4px; font-family: monospace; margin: 10px 0; display: block; }
        .btn { display: inline-block; padding: 10px 20px; background-color: #2196F3; color: white; text-decoration: none; border-radius: 4px; margin: 5px; }
        .btn-test { background-color: #4CAF50; }
        ul, ol { margin: 10px 0; padding-left: 30px; }
        li { margin: 5px 0; }
        table { width: 100%; border-collapse: collapse; margin: 15px 0; }
        th, td { padding: 12px; text-align: left; border-bottom: 1px solid #ddd; }
        th { background-color: #f5f5f5; font-weight: bold; }
    </style>
</head>
<body>
    <div class="container">
        <h1>📚 WAS 이슈 테스트 가이드</h1>
        
        <div class="warning-box">
            <strong>⚠️ 중요:</strong> 모든 테스트는 <strong>테스트/개발 환경에서만</strong> 수행하세요. 운영 환경에서는 절대 사용하지 마세요!
        </div>
        
        <div class="guide-section">
            <h2>1. OutOfMemoryError (OOME) 테스트</h2>
            <div class="test-item">
                <h4>목적</h4>
                <p>힙 메모리를 고의로 소진시켜 OutOfMemoryError를 재현합니다.</p>
                
                <h4>확인 방법</h4>
                <ol>
                    <li><a href="oome.jsp" class="btn btn-test">OOME 테스트 페이지</a>로 이동</li>
                    <li>"힙 메모리 소진 테스트 시작" 버튼 클릭</li>
                    <li>메모리 사용량이 증가하는 것을 확인</li>
                    <li>최종적으로 OutOfMemoryError 발생 확인</li>
                </ol>
                
                <h4>모니터링 포인트</h4>
                <ul>
                    <li>JVM 힙 메모리 사용량 (jstat, JConsole 등)</li>
                    <li>GC 빈도 증가</li>
                    <li>에러 로그에서 "OutOfMemoryError: Java heap space" 확인</li>
                </ul>
            </div>
        </div>
        
        <div class="guide-section">
            <h2>2. 커넥션 풀 고갈 테스트</h2>
            <div class="test-item">
                <h4>목적</h4>
                <p>데이터베이스 커넥션을 최대치까지 사용하여 커넥션 풀 고갈을 재현합니다.</p>
                
                <h4>확인 방법</h4>
                <ol>
                    <li><a href="connection_pool.jsp" class="btn btn-test">커넥션 풀 테스트 페이지</a>로 이동</li>
                    <li>DataSource가 자동 탐색되면 "DataSource 사용" 선택 (또는 직접 연결 정보 입력)</li>
                    <li>최대 커넥션 수 설정 (기본값: 100)</li>
                    <li>"커넥션 풀 고갈 테스트 시작" 버튼 클릭</li>
                    <li>커넥션 생성 과정 확인</li>
                    <li>"Maximum connections reached" 또는 "Connection pool exhausted" 에러 확인</li>
                </ol>
                
                <h4>모니터링 포인트</h4>
                <ul>
                    <li>WAS 관리 콘솔에서 커넥션 풀 사용량 확인</li>
                    <li>활성 커넥션 수 증가</li>
                    <li>대기 중인 요청 증가</li>
                    <li>새로운 요청 처리 실패</li>
                </ul>
                
                <div class="info-box">
                    <strong>💡 팁:</strong> DataSource가 설정되어 있으면 자동으로 탐색하여 사용합니다. 
                    <a href="datasource.jsp">DataSource 연동 확인</a> 페이지에서 먼저 확인하세요.
                </div>
            </div>
        </div>
        
        <div class="guide-section">
            <h2>3. 느린 쿼리 테스트</h2>
            <div class="test-item">
                <h4>목적</h4>
                <p>장시간 실행되는 쿼리를 수행하여 타임아웃을 재현합니다.</p>
                
                <h4>확인 방법</h4>
                <ol>
                    <li><a href="slow_query.jsp" class="btn btn-test">느린 쿼리 테스트 페이지</a>로 이동</li>
                    <li>DataSource 사용 또는 직접 연결 정보 입력</li>
                    <li>대기 시간 설정 (초 단위, 기본값: 30초)</li>
                    <li>또는 직접 쿼리 입력</li>
                    <li>"느린 쿼리 테스트 시작" 버튼 클릭</li>
                    <li>쿼리 실행 시간 확인</li>
                    <li>타임아웃 발생 여부 확인</li>
                </ol>
                
                <h4>모니터링 포인트</h4>
                <ul>
                    <li>쿼리 실행 시간</li>
                    <li>SQLTimeoutException 발생</li>
                    <li>커넥션 타임아웃 설정 확인</li>
                    <li>트랜잭션 타임아웃 확인</li>
                </ul>
            </div>
        </div>
        
        <div class="guide-section">
            <h2>4. 세션 누수 테스트</h2>
            <div class="test-item">
                <h4>목적</h4>
                <p>세션에 대용량 데이터를 저장하여 세션 누수를 재현합니다.</p>
                
                <h4>확인 방법</h4>
                <ol>
                    <li><a href="session_leak.jsp" class="btn btn-test">세션 누수 테스트 페이지</a>로 이동</li>
                    <li>추가할 데이터 크기 입력 (MB 단위, 기본값: 10MB)</li>
                    <li>"세션에 데이터 추가" 버튼 클릭</li>
                    <li>세션 총 크기 증가 확인</li>
                    <li>반복적으로 데이터 추가하여 메모리 증가 확인</li>
                </ol>
                
                <h4>모니터링 포인트</h4>
                <ul>
                    <li>세션 메모리 사용량</li>
                    <li>활성 세션 수</li>
                    <li>서버 힙 메모리 증가</li>
                    <li>세션 저장소 부족 경고</li>
                </ul>
            </div>
        </div>
        
        <div class="guide-section">
            <h2>5. 스레드 풀 고갈 테스트</h2>
            <div class="test-item">
                <h4>목적</h4>
                <p>대량의 스레드를 생성하여 스레드 풀 고갈을 재현합니다.</p>
                
                <h4>확인 방법</h4>
                <ol>
                    <li><a href="thread_pool.jsp" class="btn btn-test">스레드 풀 테스트 페이지</a>로 이동</li>
                    <li>생성할 스레드 수 입력 (기본값: 200)</li>
                    <li>각 스레드 대기 시간 입력 (초 단위, 기본값: 60초)</li>
                    <li>"스레드 생성 시작" 버튼 클릭</li>
                    <li>스레드 생성 과정 확인</li>
                    <li>"Thread pool exhausted" 에러 확인</li>
                </ol>
                
                <h4>모니터링 포인트</h4>
                <ul>
                    <li>JVM 활성 스레드 수 (jstack, JConsole)</li>
                    <li>스레드 풀 사용률</li>
                    <li>새로운 요청 처리 불가</li>
                    <li>응답 지연 증가</li>
                </ul>
            </div>
        </div>
        
        <div class="guide-section">
            <h2>6. 파일 핸들러 누수 테스트</h2>
            <div class="test-item">
                <h4>목적</h4>
                <p>파일 핸들을 열고 닫지 않아 파일 핸들러 누수를 재현합니다.</p>
                
                <h4>확인 방법</h4>
                <ol>
                    <li><a href="file_handle.jsp" class="btn btn-test">파일 핸들러 테스트 페이지</a>로 이동</li>
                    <li>생성할 파일 핸들 수 입력 (기본값: 500)</li>
                    <li>"파일 핸들 생성 시작" 버튼 클릭</li>
                    <li>파일 핸들 생성 과정 확인</li>
                    <li>"Too many open files" 에러 확인</li>
                </ol>
                
                <h4>모니터링 포인트</h4>
                <ul>
                    <li>프로세스별 열린 파일 수 (Linux: lsof -p &lt;pid&gt; | wc -l)</li>
                    <li>시스템 파일 핸들러 한계 확인</li>
                    <li>새로운 파일 열기 실패</li>
                </ul>
            </div>
        </div>
        
        <div class="guide-section">
            <h2>7. 캐시 누수 테스트</h2>
            <div class="test-item">
                <h4>목적</h4>
                <p>정적 캐시에 무한정 데이터를 추가하여 메모리 누수를 재현합니다.</p>
                
                <h4>확인 방법</h4>
                <ol>
                    <li><a href="cache_leak.jsp" class="btn btn-test">캐시 누수 테스트 페이지</a>로 이동</li>
                    <li>각 항목 크기 입력 (MB 단위, 기본값: 5MB)</li>
                    <li>추가할 항목 수 입력 (기본값: 20)</li>
                    <li>"캐시에 데이터 추가" 버튼 클릭</li>
                    <li>캐시 총 크기 증가 확인</li>
                    <li>반복적으로 데이터 추가하여 메모리 증가 확인</li>
                </ol>
                
                <h4>모니터링 포인트</h4>
                <ul>
                    <li>힙 메모리 지속적 증가</li>
                    <li>GC로도 회수되지 않음 (정적 캐시이므로)</li>
                    <li>서버 재시작 전까지 유지됨</li>
                </ul>
            </div>
        </div>
        
        <div class="guide-section">
            <h2>8. PermGen/Metaspace 누수 테스트</h2>
            <div class="test-item">
                <h4>목적</h4>
                <p>동적 클래스 로딩을 통한 PermGen/Metaspace 누수를 재현합니다.</p>
                
                <h4>확인 방법</h4>
                <ol>
                    <li><a href="permgen_leak.jsp" class="btn btn-test">PermGen 누수 테스트 페이지</a>로 이동</li>
                    <li>생성할 클래스 메타데이터 수 입력 (기본값: 1000)</li>
                    <li>"PermGen/Metaspace 누수 테스트 시작" 버튼 클릭</li>
                    <li>메타데이터 생성 과정 확인</li>
                    <li>"OutOfMemoryError: PermGen space" 또는 "Metaspace" 에러 확인</li>
                </ol>
                
                <h4>모니터링 포인트</h4>
                <ul>
                    <li>Java 7 이하: PermGen 사용량</li>
                    <li>Java 8+: Metaspace 사용량</li>
                    <li>클래스 로딩 실패</li>
                </ul>
            </div>
        </div>
        
        <div class="guide-section">
            <h2>9. 데드락 시뮬레이션</h2>
            <div class="test-item">
                <h4>목적</h4>
                <p>여러 스레드가 서로의 리소스를 기다리는 데드락을 재현합니다.</p>
                
                <h4>확인 방법</h4>
                <ol>
                    <li><a href="deadlock.jsp" class="btn btn-test">데드락 테스트 페이지</a>로 이동</li>
                    <li>"데드락 시뮬레이션 시작" 버튼 클릭</li>
                    <li>두 스레드가 블로킹된 상태 확인</li>
                    <li>스레드 덤프에서 데드락 확인 (jstack)</li>
                </ol>
                
                <h4>모니터링 포인트</h4>
                <ul>
                    <li>스레드 덤프 분석 (jstack &lt;pid&gt;)</li>
                    <li>블로킹된 스레드 확인</li>
                    <li>응답 지연</li>
                </ul>
            </div>
        </div>
        
        <div class="guide-section">
            <h2>10. CPU 과부하 테스트</h2>
            <div class="test-item">
                <h4>목적</h4>
                <p>무한 루프를 통한 CPU 100% 사용을 재현합니다.</p>
                
                <h4>확인 방법</h4>
                <ol>
                    <li><a href="cpu_overload.jsp" class="btn btn-test">CPU 과부하 테스트 페이지</a>로 이동</li>
                    <li>생성할 스레드 수 입력 (기본값: CPU 코어 수)</li>
                    <li>지속 시간 입력 (초 단위, 기본값: 30초)</li>
                    <li>"CPU 과부하 테스트 시작" 버튼 클릭</li>
                    <li>CPU 사용률 100% 확인</li>
                </ol>
                
                <h4>모니터링 포인트</h4>
                <ul>
                    <li>CPU 사용률 (top, htop, 작업 관리자)</li>
                    <li>서버 응답 지연</li>
                    <li>다른 요청 처리 불가</li>
                </ul>
            </div>
        </div>
        
        <div class="guide-section">
            <h2>11. 클러스터링 테스트</h2>
            <div class="test-item">
                <h4>목적</h4>
                <p>클러스터 환경에서 세션 어피니티, WLCookie, 세션 복제를 확인합니다.</p>
                
                <h4>확인 방법</h4>
                <ol>
                    <li><a href="clustering.jsp" class="btn btn-test">클러스터링 테스트 페이지</a>로 이동</li>
                    <li>서버 정보 확인 (서버 이름, 포트, IP 주소)</li>
                    <li>세션 정보 확인 (세션 ID, 생성 시간)</li>
                    <li>쿠키 정보 확인 (JSESSIONID, WLCookie 등)</li>
                    <li>세션에 테스트 데이터 저장</li>
                    <li>다른 서버 노드에서 같은 세션으로 접근하여 세션 복제 확인</li>
                </ol>
                
                <h4>모니터링 포인트</h4>
                <ul>
                    <li>WLCookie 존재 여부 (WebLogic 클러스터)</li>
                    <li>세션 ID 일관성</li>
                    <li>서버 간 세션 데이터 동기화</li>
                    <li>HTTP 헤더 정보</li>
                </ul>
            </div>
        </div>
        
        <div class="guide-section">
            <h2>12. DataSource 연동 확인</h2>
            <div class="test-item">
                <h4>목적</h4>
                <p>JNDI를 통한 DataSource 연결 및 커넥션 정보를 확인합니다.</p>
                
                <h4>확인 방법</h4>
                <ol>
                    <li><a href="datasource.jsp" class="btn btn-test">DataSource 연동 확인 페이지</a>로 이동</li>
                    <li>JNDI 이름 입력 (또는 자동 탐색된 DataSource 사용)</li>
                    <li>테스트 쿼리 입력 (선택사항)</li>
                    <li>"DataSource 연결 테스트" 버튼 클릭</li>
                    <li>데이터베이스 정보 확인</li>
                </ol>
                
                <h4>확인 항목</h4>
                <ul>
                    <li>데이터베이스 제품명 및 버전</li>
                    <li>JDBC 드라이버 정보</li>
                    <li>연결 URL, 사용자명</li>
                    <li>스키마, 카탈로그 정보</li>
                    <li>쿼리 실행 결과</li>
                </ul>
                
                <div class="info-box">
                    <strong>💡 참고:</strong> 이 페이지에서 확인한 DataSource는 다른 DB 관련 테스트(커넥션 풀, 느린 쿼리)에서 자동으로 사용됩니다.
                </div>
            </div>
        </div>
        
        <div class="guide-section">
            <h2>📊 공통 모니터링 도구</h2>
            <div class="test-item">
                <h4>JVM 모니터링</h4>
                <ul>
                    <li><strong>jstat:</strong> GC 및 메모리 통계 <span class="code">jstat -gc &lt;pid&gt; 1000</span></li>
                    <li><strong>jstack:</strong> 스레드 덤프 <span class="code">jstack &lt;pid&gt;</span></li>
                    <li><strong>jmap:</strong> 힙 덤프 <span class="code">jmap -dump:format=b,file=heap.bin &lt;pid&gt;</span></li>
                    <li><strong>JConsole:</strong> GUI 기반 모니터링</li>
                    <li><strong>VisualVM:</strong> 고급 프로파일링</li>
                </ul>
                
                <h4>시스템 모니터링</h4>
                <ul>
                    <li><strong>CPU:</strong> top, htop, 작업 관리자</li>
                    <li><strong>메모리:</strong> free, 작업 관리자</li>
                    <li><strong>파일 핸들러:</strong> lsof -p &lt;pid&gt; | wc -l</li>
                    <li><strong>네트워크:</strong> netstat, ss</li>
                </ul>
                
                <h4>WAS 관리 콘솔</h4>
                <ul>
                    <li><strong>WebLogic:</strong> Administration Console</li>
                    <li><strong>Tomcat:</strong> Manager Application</li>
                    <li><strong>JBoss:</strong> Administration Console</li>
                </ul>
            </div>
        </div>
        
        <div class="guide-section">
            <h2>⚠️ 테스트 후 정리</h2>
            <div class="warning-box">
                <p><strong>중요:</strong> 각 테스트 후 생성된 리소스를 반드시 정리하세요!</p>
                <ul>
                    <li>커넥션 풀: "커넥션 해제" 버튼 클릭</li>
                    <li>세션 누수: "세션 데이터 삭제" 버튼 클릭</li>
                    <li>스레드 풀: "모든 스레드 중단" 버튼 클릭</li>
                    <li>파일 핸들러: "모든 파일 핸들 닫기" 버튼 클릭</li>
                    <li>캐시 누수: "캐시 비우기" 버튼 클릭</li>
                    <li>또는 서버 재시작</li>
                </ul>
            </div>
        </div>
        
        <div style="margin-top: 30px; text-align: center;">
            <a href="index.jsp" class="btn">메인으로 돌아가기</a>
        </div>
    </div>
</body>
</html>
