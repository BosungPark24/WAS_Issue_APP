<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
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
    <title>커넥션 풀 고갈 테스트</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; background-color: #f5f5f5; }
        .container { max-width: 800px; margin: 0 auto; background: white; padding: 20px; border-radius: 8px; }
        .warning { background-color: #ffebee; border-left: 4px solid #f44336; padding: 15px; margin: 20px 0; }
        .info { background-color: #e3f2fd; padding: 10px; margin: 10px 0; border-radius: 4px; }
        .success { background-color: #e8f5e9; padding: 10px; margin: 10px 0; border-radius: 4px; }
        .error { background-color: #ffebee; padding: 10px; margin: 10px 0; border-radius: 4px; }
        .btn { display: inline-block; padding: 10px 20px; background-color: #2196F3; color: white; text-decoration: none; border-radius: 4px; margin: 5px; border: none; cursor: pointer; }
        .btn-danger { background-color: #f44336; }
        input[type="text"] { width: 300px; padding: 8px; margin: 5px 0; }
        .auto-detect { background-color: #fff3cd; border-left: 4px solid #ffc107; padding: 15px; margin: 20px 0; }
    </style>
</head>
<body>
    <div class="container">
        <h1>커넥션 풀 고갈 테스트</h1>
        
        <div class="warning">
            <strong>⚠️ 경고:</strong> 이 테스트는 데이터베이스 커넥션을 최대치까지 사용하여 커넥션 풀 고갈을 재현합니다.
        </div>
        
        <%
            String action = request.getParameter("action");
            String useDataSource = request.getParameter("useDataSource");
            String driver = request.getParameter("driver");
            String url = request.getParameter("url");
            String username = request.getParameter("username");
            String password = request.getParameter("password");
            String maxConnections = request.getParameter("maxConnections");
            
            // DataSource 자동 탐색
            DataSource dataSource = findDataSource(pageContext);
            String foundJndiName = findDataSourceJndiName();
            boolean hasDataSource = (dataSource != null);
            
            if ("test".equals(action)) {
                @SuppressWarnings("unchecked")
                List<Connection> existingConnections = (List<Connection>) session.getAttribute("test_connections");
                if (existingConnections != null && !existingConnections.isEmpty()) {
                    int autoClosed = 0;
                    for (Connection existingConn : existingConnections) {
                        try {
                            if (existingConn != null && !existingConn.isClosed()) {
                                existingConn.close();
                                autoClosed++;
                            }
                        } catch (SQLException ignore) {
                            // ignore cleanup failure for old test resources
                        }
                    }
                    session.removeAttribute("test_connections");
                    out.println("<div class='info'>이전 테스트 커넥션 " + autoClosed + "개를 자동 정리했습니다.</div>");
                }

                List<Connection> connections = new ArrayList<Connection>();
                int maxConn = 100;
                if (maxConnections != null && !maxConnections.isEmpty()) {
                    try {
                        maxConn = Integer.parseInt(maxConnections);
                    } catch (NumberFormatException e) {
                        maxConn = 100;
                    }
                }
                
                int successCount = 0;
                int failCount = 0;
                String lastError = null;
                boolean usingDataSource = ("true".equals(useDataSource) || (useDataSource == null && hasDataSource));
                
                try {
                    if (usingDataSource && dataSource != null) {
                        // DataSource 사용
                        out.println("<div class='success'>DataSource 사용: " + h(foundJndiName) + "</div>");
                        out.println("<div class='info'>커넥션 생성 시작... (최대 " + maxConn + "개)</div>");
                        out.flush();
                        
                        for (int i = 0; i < maxConn; i++) {
                            try {
                                Connection conn = dataSource.getConnection();
                                connections.add(conn);
                                successCount++;
                                
                                if ((i + 1) % 10 == 0) {
                                    out.println("<div class='info'>" + (i + 1) + "개 커넥션 생성됨...</div>");
                                    out.flush();
                                }
                            } catch (SQLException e) {
                                failCount++;
                                lastError = e.getMessage();
                                if (e.getMessage().contains("maximum") || e.getMessage().contains("exhausted") || 
                                    e.getMessage().contains("timeout") || e.getMessage().contains("pool")) {
                                    break;
                                }
                            }
                        }
                    } else if (driver != null && url != null) {
                        // 직접 연결 사용
                        Class.forName(driver);
                        out.println("<div class='info'>직접 연결 사용 (JDBC URL)</div>");
                        out.println("<div class='info'>커넥션 생성 시작... (최대 " + maxConn + "개)</div>");
                        out.flush();
                        
                        for (int i = 0; i < maxConn; i++) {
                            try {
                                Connection conn = null;
                                if (username != null && !username.isEmpty()) {
                                    conn = DriverManager.getConnection(url, username, password != null ? password : "");
                                } else {
                                    conn = DriverManager.getConnection(url);
                                }
                                
                                connections.add(conn);
                                successCount++;
                                
                                if ((i + 1) % 10 == 0) {
                                    out.println("<div class='info'>" + (i + 1) + "개 커넥션 생성됨...</div>");
                                    out.flush();
                                }
                            } catch (SQLException e) {
                                failCount++;
                                lastError = e.getMessage();
                                if (e.getMessage().contains("maximum") || e.getMessage().contains("exhausted") || 
                                    e.getMessage().contains("timeout") || e.getMessage().contains("pool")) {
                                    break;
                                }
                            }
                        }
                    } else {
                        out.println("<div class='error'>연결 방법을 선택하거나 직접 연결 정보를 입력하세요.</div>");
                    }
                    
                    if (successCount > 0 || failCount > 0) {
                        out.println("<div class='success'>");
                        out.println("<h3>테스트 결과</h3>");
                        out.println("<p><strong>성공한 커넥션:</strong> " + successCount + "개</p>");
                        out.println("<p><strong>실패한 커넥션:</strong> " + failCount + "개</p>");
                        if (lastError != null) {
                            out.println("<p><strong>마지막 에러:</strong> " + h(lastError) + "</p>");
                        }
                        out.println("</div>");
                        
                        // 커넥션을 닫지 않고 유지 (누수 시뮬레이션)
                        out.println("<div class='warning'>");
                        out.println("<p><strong>주의:</strong> " + connections.size() + "개의 커넥션이 열린 상태로 유지됩니다.</p>");
                        out.println("<p>이것이 커넥션 풀 고갈의 원인입니다. 아래 버튼으로 커넥션을 해제하세요.</p>");
                        out.println("</div>");
                        
                        // 세션에 저장하여 나중에 정리할 수 있도록
                        session.setAttribute("test_connections", connections);
                    }
                    
                } catch (ClassNotFoundException e) {
                    out.println("<div class='error'><strong>에러:</strong> JDBC 드라이버를 찾을 수 없습니다: " + h(e.getMessage()) + "</div>");
                } catch (Exception e) {
                    out.println("<div class='error'><strong>에러:</strong> " + h(e.getMessage()) + "</div>");
                }
            } else if ("release".equals(action)) {
                @SuppressWarnings("unchecked")
                List<Connection> connections = (List<Connection>) session.getAttribute("test_connections");
                if (connections != null) {
                    int closed = 0;
                    for (Connection conn : connections) {
                        try {
                            if (conn != null && !conn.isClosed()) {
                                conn.close();
                                closed++;
                            }
                        } catch (SQLException e) {
                            // 무시
                        }
                    }
                    session.removeAttribute("test_connections");
                    out.println("<div class='success'>" + closed + "개의 커넥션이 해제되었습니다.</div>");
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
            <h3>커넥션 풀 고갈 테스트</h3>
            <p>데이터베이스 커넥션을 최대치까지 사용하여 커넥션 풀 고갈을 재현합니다.</p>
            <p><strong>주의:</strong> 실제 운영 DB에 연결하지 마세요. 테스트용 DB를 사용하세요.</p>
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
                    <input type="text" name="driver" value="<%= h(driver != null ? driver : "oracle.jdbc.driver.OracleDriver") %>" 
                           placeholder="예: oracle.jdbc.driver.OracleDriver">
                </p>
                <p>
                    <label>JDBC URL:</label><br>
                    <input type="text" name="url" value="<%= h(url != null ? url : "") %>" 
                           placeholder="예: jdbc:oracle:thin:@localhost:1521:XE">
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
                <label>최대 커넥션 수:</label><br>
                <input type="text" name="maxConnections" value="<%= h(maxConnections != null ? maxConnections : "100") %>">
            </p>
            
            <button type="submit" class="btn btn-danger">커넥션 풀 고갈 테스트 시작</button>
        </form>
        
        <% if (session.getAttribute("test_connections") != null) { %>
        <form method="post" style="margin-top: 20px;">
            <input type="hidden" name="action" value="release">
            <button type="submit" class="btn">커넥션 해제</button>
        </form>
        <% } %>
        
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
