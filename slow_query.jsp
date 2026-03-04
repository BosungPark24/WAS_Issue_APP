<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="javax.sql.DataSource" %>
<%@ page import="javax.naming.*" %>
<%@ include file="WEB-INF/jsp/datasource_util.jsp" %>
<%!
    private static String h(Object value) {
        if (value == null) return "";
        String s = String.valueOf(value);
        return s.replace("&", "&amp;")
                .replace("<", "&lt;")
                .replace(">", "&gt;")
                .replace("\"", "&quot;")
                .replace("'", "&#x27;");
    }
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>느린 쿼리 테스트</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; background-color: #f5f5f5; }
        .container { max-width: 800px; margin: 0 auto; background: white; padding: 20px; border-radius: 8px; }
        .warning { background-color: #ffebee; border-left: 4px solid #f44336; padding: 15px; margin: 20px 0; }
        .info { background-color: #e3f2fd; padding: 10px; margin: 10px 0; border-radius: 4px; }
        .success { background-color: #e8f5e9; padding: 10px; margin: 10px 0; border-radius: 4px; }
        .error { background-color: #ffebee; padding: 10px; margin: 10px 0; border-radius: 4px; }
        .btn { display: inline-block; padding: 10px 20px; background-color: #2196F3; color: white; text-decoration: none; border-radius: 4px; margin: 5px; border: none; cursor: pointer; }
        .btn-danger { background-color: #f44336; }
        input[type="text"], textarea { width: 100%; padding: 8px; margin: 5px 0; box-sizing: border-box; }
        textarea { height: 100px; }
        .auto-detect { background-color: #fff3cd; border-left: 4px solid #ffc107; padding: 15px; margin: 20px 0; }
    </style>
</head>
<body>
    <div class="container">
        <h1>느린 쿼리 테스트</h1>
        
        <div class="warning">
            <strong>⚠️ 경고:</strong> 이 테스트는 장시간 실행되는 쿼리를 수행하여 타임아웃을 재현합니다.
        </div>
        
        <%
            String action = request.getParameter("action");
            String useDataSource = request.getParameter("useDataSource");
            String driver = request.getParameter("driver");
            String url = request.getParameter("url");
            String username = request.getParameter("username");
            String password = request.getParameter("password");
            String query = request.getParameter("query");
            String sleepSeconds = request.getParameter("sleepSeconds");
            
            // DataSource 자동 탐색
            DataSource dataSource = findDataSource(pageContext);
            String foundJndiName = findDataSourceJndiName();
            boolean hasDataSource = (dataSource != null);
            
            if ("test".equals(action)) {
                Connection conn = null;
                Statement stmt = null;
                long startTime = System.currentTimeMillis();
                boolean usingDataSource = ("true".equals(useDataSource) || (useDataSource == null && hasDataSource));
                
                try {
                    if (usingDataSource && dataSource != null) {
                        // DataSource 사용
                        conn = dataSource.getConnection();
                        out.println("<div class='success'>DataSource 사용: " + h(foundJndiName) + "</div>");
                    } else if (driver != null && url != null) {
                        // 직접 연결 사용
                        Class.forName(driver);
                        if (username != null && !username.isEmpty()) {
                            conn = DriverManager.getConnection(url, username, password != null ? password : "");
                        } else {
                            conn = DriverManager.getConnection(url);
                        }
                        out.println("<div class='info'>직접 연결 사용 (JDBC URL)</div>");
                    } else {
                        out.println("<div class='error'>연결 방법을 선택하거나 직접 연결 정보를 입력하세요.</div>");
                    }
                    
                    if (conn != null) {
                        int sleepTime = 10; // 기본 10초
                        if (sleepSeconds != null && !sleepSeconds.isEmpty()) {
                            try {
                                sleepTime = Integer.parseInt(sleepSeconds);
                            } catch (NumberFormatException e) {
                                sleepTime = 10;
                            }
                        }
                        
                        stmt = conn.createStatement();
                        
                        if (query != null && !query.trim().isEmpty()) {
                            out.println("<div class='info'>쿼리 실행 중: " + h(query) + "</div>");
                            out.println("<div class='info'>예상 대기 시간: " + sleepTime + "초</div>");
                            out.flush();
                            
                            // 쿼리 실행
                            boolean hasResultSet = stmt.execute(query);
                            
                            if (hasResultSet) {
                                ResultSet rs = stmt.getResultSet();
                                int rowCount = 0;
                                while (rs.next()) {
                                    rowCount++;
                                }
                                rs.close();
                                out.println("<div class='success'>쿼리 완료. 결과 행 수: " + rowCount + "</div>");
                            } else {
                                int updateCount = stmt.getUpdateCount();
                                out.println("<div class='success'>쿼리 완료. 영향받은 행 수: " + updateCount + "</div>");
                            }
                        } else {
                            // DB 타입 확인 (DataSource에서)
                            DatabaseMetaData metaData = conn.getMetaData();
                            String dbProductName = metaData.getDatabaseProductName().toLowerCase();
                            
                            if (dbProductName.contains("oracle")) {
                                out.println("<div class='info'>Oracle 느린 쿼리 시뮬레이션 실행 중...</div>");
                                out.flush();
                                
                                try {
                                    stmt.execute("BEGIN DBMS_LOCK.SLEEP(" + sleepTime + "); END;");
                                    out.println("<div class='success'>Oracle SLEEP 완료 (" + sleepTime + "초)</div>");
                                } catch (SQLException e) {
                                    out.println("<div class='info'>DBMS_LOCK 권한이 없어 대체 방법 사용...</div>");
                                    out.flush();
                                    
                                    for (int i = 0; i < sleepTime; i++) {
                                        Thread.sleep(1000);
                                        out.println("<div class='info'>대기 중... " + (i + 1) + "/" + sleepTime + "초</div>");
                                        out.flush();
                                    }
                                    out.println("<div class='success'>대기 완료 (" + sleepTime + "초)</div>");
                                }
                            } else if (dbProductName.contains("mysql")) {
                                out.println("<div class='info'>MySQL SLEEP 함수 실행 중...</div>");
                                out.flush();
                                stmt.execute("SELECT SLEEP(" + sleepTime + ")");
                                out.println("<div class='success'>MySQL SLEEP 완료 (" + sleepTime + "초)</div>");
                            } else if (dbProductName.contains("postgresql")) {
                                out.println("<div class='info'>PostgreSQL pg_sleep 함수 실행 중...</div>");
                                out.flush();
                                stmt.execute("SELECT pg_sleep(" + sleepTime + ")");
                                out.println("<div class='success'>PostgreSQL pg_sleep 완료 (" + sleepTime + "초)</div>");
                            } else {
                                out.println("<div class='info'>일반 대기 시뮬레이션 실행 중...</div>");
                                out.flush();
                                for (int i = 0; i < sleepTime; i++) {
                                    Thread.sleep(1000);
                                    out.println("<div class='info'>대기 중... " + (i + 1) + "/" + sleepTime + "초</div>");
                                    out.flush();
                                }
                                out.println("<div class='success'>대기 완료 (" + sleepTime + "초)</div>");
                            }
                        }
                        
                        long endTime = System.currentTimeMillis();
                        long duration = (endTime - startTime) / 1000;
                        out.println("<div class='info'><strong>총 실행 시간:</strong> " + duration + "초</div>");
                    }
                    
                } catch (SQLTimeoutException e) {
                    long endTime = System.currentTimeMillis();
                    long duration = (endTime - startTime) / 1000;
                    out.println("<div class='error'>");
                    out.println("<h3>쿼리 타임아웃 발생!</h3>");
                    out.println("<p><strong>에러:</strong> " + h(e.getMessage()) + "</p>");
                    out.println("<p><strong>실행 시간:</strong> " + duration + "초</p>");
                    out.println("</div>");
                } catch (SQLException e) {
                    out.println("<div class='error'><strong>SQL 에러:</strong> " + h(e.getMessage()) + "</div>");
                } catch (ClassNotFoundException e) {
                    out.println("<div class='error'><strong>에러:</strong> JDBC 드라이버를 찾을 수 없습니다: " + h(e.getMessage()) + "</div>");
                } catch (InterruptedException e) {
                    out.println("<div class='error'><strong>에러:</strong> 대기 중단됨</div>");
                } finally {
                    try {
                        if (stmt != null) stmt.close();
                        if (conn != null) conn.close();
                    } catch (SQLException e) {
                        // 무시
                    }
                }
            }
        %>
        
        <!-- DataSource 자동 탐색 결과 -->
        <% if (hasDataSource) { %>
        <div class="auto-detect">
            <h3>✅ DataSource 자동 탐색 성공</h3>
            <p><strong>발견된 JNDI 이름:</strong> <code><%= h(foundJndiName) %></code></p>
            <p>아래 "DataSource 사용" 옵션을 선택하면 자동으로 이 DataSource를 사용합니다.</p>
        </div>
        <% } else { %>
        <div class="info">
            <h3>DataSource 자동 탐색</h3>
            <p>DataSource를 찾을 수 없습니다. 직접 연결 정보를 입력하거나 <a href="datasource.jsp">DataSource 연동 확인</a> 페이지에서 설정하세요.</p>
        </div>
        <% } %>
        
        <div class="info">
            <h3>느린 쿼리 테스트 옵션</h3>
            <p>데이터베이스에서 장시간 실행되는 쿼리를 수행하여 타임아웃을 재현합니다.</p>
        </div>
        
        <form method="post">
            <input type="hidden" name="action" value="test">
            
            <% if (hasDataSource) { %>
            <div style="margin: 15px 0; padding: 15px; background-color: #f0f0f0; border-radius: 4px;">
                <label>
                    <input type="radio" name="useDataSource" value="true" checked> 
                    <strong>DataSource 사용</strong> (<code><%= h(foundJndiName) %></code>)
                </label><br>
                <label style="margin-top: 10px; display: block;">
                    <input type="radio" name="useDataSource" value="false"> 
                    직접 연결 정보 입력
                </label>
            </div>
            <% } else { %>
            <input type="hidden" name="useDataSource" value="false">
            <% } %>
            
            <div id="directConnection" style="<%= hasDataSource ? "display:none;" : "" %>">
                <p>
                    <label>JDBC Driver:</label><br>
                    <input type="text" name="driver" value="<%= h(driver != null ? driver : "oracle.jdbc.driver.OracleDriver") %>">
                </p>
                <p>
                    <label>JDBC URL:</label><br>
                    <input type="text" name="url" value="<%= h(url != null ? url : "") %>">
                </p>
                <p>
                    <label>Username:</label><br>
                    <input type="text" name="username" value="<%= h(username != null ? username : "") %>">
                </p>
                <p>
                    <label>Password:</label><br>
                    <input type="text" name="password" value="<%= h(password != null ? password : "") %>">
                </p>
            </div>
            
            <p>
                <label>대기 시간 (초):</label><br>
                <input type="text" name="sleepSeconds" value="<%= h(sleepSeconds != null ? sleepSeconds : "30") %>">
            </p>
            <p>
                <label>또는 직접 쿼리 입력 (선택사항):</label><br>
                <textarea name="query" placeholder="예: SELECT * FROM large_table WHERE complex_condition"><%= h(query != null ? query : "") %></textarea>
            </p>
            <button type="submit" class="btn btn-danger">느린 쿼리 테스트 시작</button>
        </form>
        
        <div style="margin-top: 20px;">
            <a href="index.jsp" class="btn">메인으로 돌아가기</a>
            <a href="datasource.jsp" class="btn">DataSource 연동 확인</a>
        </div>
    </div>
    
    <script>
        // 라디오 버튼 변경 시 직접 연결 입력 필드 표시/숨김
        var radios = document.querySelectorAll('input[name="useDataSource"]');
        var directConnection = document.getElementById('directConnection');
        if (radios.length > 0) {
            radios.forEach(function(radio) {
                radio.addEventListener('change', function() {
                    if (this.value === 'false') {
                        directConnection.style.display = 'block';
                    } else {
                        directConnection.style.display = 'none';
                    }
                });
            });
        }
    </script>
</body>
</html>
