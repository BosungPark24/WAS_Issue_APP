<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="javax.sql.DataSource" %>
<%@ page import="javax.naming.*" %>
<%@ page import="java.util.*" %>
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
    <title>DataSource 연동 확인</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; background-color: #f5f5f5; }
        .container { max-width: 1000px; margin: 0 auto; background: white; padding: 20px; border-radius: 8px; }
        .info { background-color: #e3f2fd; padding: 15px; margin: 10px 0; border-radius: 4px; border-left: 4px solid #2196F3; }
        .success { background-color: #e8f5e9; padding: 15px; margin: 10px 0; border-radius: 4px; border-left: 4px solid #4CAF50; }
        .warning { background-color: #fff3cd; padding: 15px; margin: 10px 0; border-radius: 4px; border-left: 4px solid #ffc107; }
        .error { background-color: #ffebee; padding: 15px; margin: 10px 0; border-radius: 4px; border-left: 4px solid #f44336; }
        table { width: 100%; border-collapse: collapse; margin: 15px 0; }
        th, td { padding: 12px; text-align: left; border-bottom: 1px solid #ddd; }
        th { background-color: #f5f5f5; font-weight: bold; }
        .btn { display: inline-block; padding: 10px 20px; background-color: #2196F3; color: white; text-decoration: none; border-radius: 4px; margin: 5px; border: none; cursor: pointer; }
        .btn-success { background-color: #4CAF50; }
        .btn-danger { background-color: #f44336; }
        input[type="text"], select { width: 100%; padding: 8px; margin: 5px 0; box-sizing: border-box; }
        .code { background-color: #f5f5f5; padding: 10px; border-radius: 4px; font-family: monospace; margin: 10px 0; overflow-x: auto; }
        .badge { display: inline-block; padding: 3px 8px; background-color: #4CAF50; color: white; border-radius: 3px; font-size: 12px; margin: 2px; }
        .badge-error { background-color: #f44336; }
    </style>
</head>
<body>
    <div class="container">
        <h1>💾 DataSource 연동 확인</h1>
        
        <div class="info">
            <h3>DataSource 연결 테스트</h3>
            <p>JNDI를 통해 DataSource를 조회하고 연결을 테스트할 수 있습니다.</p>
        </div>
        
        <%
            String action = request.getParameter("action");
            String jndiName = request.getParameter("jndiName");
            String testQuery = request.getParameter("testQuery");
            
            if (jndiName == null || jndiName.isEmpty()) {
                jndiName = "jdbc/myDataSource"; // 기본값
            }
            if (testQuery == null || testQuery.isEmpty()) {
                testQuery = "SELECT 1 FROM DUAL"; // Oracle 기본
            }
            
            Connection testConnection = null;
            DataSource dataSource = null;
            String errorMessage = null;
            Map<String, String> connectionInfo = new HashMap<String, String>();
            
            if ("test".equals(action) && jndiName != null && !jndiName.isEmpty()) {
                try {
                    // JNDI 컨텍스트 생성
                    Context ctx = new InitialContext();
                    
                    // DataSource 조회
                    Object obj = ctx.lookup(jndiName);
                    if (obj instanceof DataSource) {
                        dataSource = (DataSource) obj;
                        
                        // 커넥션 획득
                        testConnection = dataSource.getConnection();
                        
                        // 커넥션 정보 수집
                        DatabaseMetaData metaData = testConnection.getMetaData();
                        connectionInfo.put("Database Product Name", metaData.getDatabaseProductName());
                        connectionInfo.put("Database Product Version", metaData.getDatabaseProductVersion());
                        connectionInfo.put("Driver Name", metaData.getDriverName());
                        connectionInfo.put("Driver Version", metaData.getDriverVersion());
                        connectionInfo.put("JDBC Major Version", String.valueOf(metaData.getJDBCMajorVersion()));
                        connectionInfo.put("JDBC Minor Version", String.valueOf(metaData.getJDBCMinorVersion()));
                        connectionInfo.put("URL", metaData.getURL());
                        connectionInfo.put("Username", metaData.getUserName());
                        connectionInfo.put("Read Only", String.valueOf(testConnection.isReadOnly()));
                        connectionInfo.put("Auto Commit", String.valueOf(testConnection.getAutoCommit()));
                        connectionInfo.put("Catalog", testConnection.getCatalog() != null ? testConnection.getCatalog() : "N/A");
                        connectionInfo.put("Schema", testConnection.getSchema() != null ? testConnection.getSchema() : "N/A");
                        
                        // 쿼리 테스트
                        if (testQuery != null && !testQuery.trim().isEmpty()) {
                            try {
                                Statement stmt = testConnection.createStatement();
                                boolean hasResult = stmt.execute(testQuery);
                                
                                if (hasResult) {
                                    ResultSet rs = stmt.getResultSet();
                                    ResultSetMetaData rsmd = rs.getMetaData();
                                    int columnCount = rsmd.getColumnCount();
                                    
                                    // 결과가 있으면 첫 번째 행만 표시
                                    if (rs.next()) {
                                        connectionInfo.put("Query Result", "Success - " + columnCount + " column(s)");
                                        for (int i = 1; i <= columnCount; i++) {
                                            connectionInfo.put("Column " + i + " (" + rsmd.getColumnName(i) + ")", 
                                                rs.getString(i) != null ? rs.getString(i) : "NULL");
                                        }
                                    } else {
                                        connectionInfo.put("Query Result", "Success - No rows returned");
                                    }
                                    rs.close();
                                    stmt.close();
                                } else {
                                    int updateCount = stmt.getUpdateCount();
                                    connectionInfo.put("Query Result", "Success - " + updateCount + " row(s) affected");
                                    stmt.close();
                                }
                            } catch (SQLException e) {
                                connectionInfo.put("Query Error", e.getMessage());
                            }
                        }
                        
                    } else {
                        errorMessage = "JNDI 이름 '" + jndiName + "'는 DataSource가 아닙니다. 타입: " + obj.getClass().getName();
                    }
                    
                } catch (NamingException e) {
                    errorMessage = "JNDI 조회 실패: " + e.getMessage();
                } catch (SQLException e) {
                    errorMessage = "데이터베이스 연결 실패: " + e.getMessage();
                } catch (Exception e) {
                    errorMessage = "에러 발생: " + e.getMessage();
                } finally {
                    if (testConnection != null) {
                        try {
                            testConnection.close();
                        } catch (SQLException e) {
                            // 무시
                        }
                    }
                }
            }
        %>
        
        <!-- JNDI 조회 폼 -->
        <div class="info">
            <h3>🔍 DataSource 조회 및 테스트</h3>
            <form method="post">
                <input type="hidden" name="action" value="test">
                <p>
                    <label>JNDI 이름:</label>
                    <input type="text" name="jndiName" value="<%= h(jndiName) %>" 
                           placeholder="예: jdbc/myDataSource, java:comp/env/jdbc/TestDB">
                </p>
                <p>
                    <label>테스트 쿼리 (선택사항):</label>
                    <input type="text" name="testQuery" value="<%= h(testQuery) %>" 
                           placeholder="예: SELECT 1 FROM DUAL (Oracle), SELECT 1 (MySQL/PostgreSQL)">
                </p>
                <button type="submit" class="btn btn-success">DataSource 연결 테스트</button>
            </form>
        </div>
        
        <!-- 결과 표시 -->
        <% if (errorMessage != null) { %>
        <div class="error">
            <h3>❌ 연결 실패</h3>
            <p><strong>에러:</strong> <%= h(errorMessage) %></p>
            <div class="warning" style="margin-top: 15px;">
                <h4>일반적인 JNDI 이름 예시:</h4>
                <ul>
                    <li><strong>Tomcat:</strong> java:comp/env/jdbc/DataSourceName</li>
                    <li><strong>WebLogic:</strong> jdbc/DataSourceName</li>
                    <li><strong>JBoss:</strong> java:/jdbc/DataSourceName 또는 java:jboss/datasources/DataSourceName</li>
                    <li><strong>JEUS:</strong> jdbc/DataSourceName</li>
                </ul>
            </div>
        </div>
        <% } else if (!connectionInfo.isEmpty()) { %>
        <div class="success">
            <h3>✅ 연결 성공</h3>
            <table>
                <tr>
                    <th>항목</th>
                    <th>값</th>
                </tr>
                <tr>
                    <td><strong>JNDI 이름</strong></td>
                    <td><span class="code"><%= h(jndiName) %></span></td>
                </tr>
                <%
                    for (Map.Entry<String, String> entry : connectionInfo.entrySet()) {
                %>
                <tr>
                    <td><strong><%= h(entry.getKey()) %></strong></td>
                    <td><span class="code"><%= h(entry.getValue()) %></span></td>
                </tr>
                <%
                    }
                %>
            </table>
        </div>
        <% } %>
        
        <!-- 일반적인 JNDI 이름 목록 -->
        <div class="info">
            <h3>📋 일반적인 DataSource JNDI 이름</h3>
            <table>
                <tr>
                    <th>WAS</th>
                    <th>JNDI 이름 패턴</th>
                    <th>예시</th>
                </tr>
                <tr>
                    <td><strong>Tomcat</strong></td>
                    <td>java:comp/env/jdbc/...</td>
                    <td>java:comp/env/jdbc/myDB</td>
                </tr>
                <tr>
                    <td><strong>WebLogic</strong></td>
                    <td>jdbc/...</td>
                    <td>jdbc/myDataSource</td>
                </tr>
                <tr>
                    <td><strong>JBoss/WildFly</strong></td>
                    <td>java:/jdbc/... 또는 java:jboss/datasources/...</td>
                    <td>java:/jdbc/ExampleDS<br>java:jboss/datasources/ExampleDS</td>
                </tr>
                <tr>
                    <td><strong>JEUS</strong></td>
                    <td>jdbc/...</td>
                    <td>jdbc/myDataSource</td>
                </tr>
            </table>
        </div>
        
        <!-- JNDI 컨텍스트 탐색 (시도) -->
        <div class="info">
            <h3>🔎 JNDI 컨텍스트 탐색</h3>
            <%
                List<String> foundJndiNames = new ArrayList<String>();
                try {
                    Context ctx = new InitialContext();
                    
                    // 일반적인 컨텍스트 경로 시도
                    String[] contexts = {
                        "java:comp/env/jdbc",
                        "jdbc",
                        "java:/jdbc",
                        "java:jboss/datasources"
                    };
                    
                    for (String contextPath : contexts) {
                        try {
                            Context subCtx = (Context) ctx.lookup(contextPath);
                            NamingEnumeration<NameClassPair> list = subCtx.list("");
                            while (list.hasMoreElements()) {
                                NameClassPair pair = list.nextElement();
                                foundJndiNames.add(contextPath + "/" + pair.getName());
                            }
                        } catch (Exception e) {
                            // 해당 컨텍스트가 없으면 무시
                        }
                    }
                } catch (Exception e) {
                    // JNDI 초기화 실패
                }
            %>
            
            <% if (!foundJndiNames.isEmpty()) { %>
                <p><strong>발견된 DataSource:</strong></p>
                <ul>
                    <% for (String name : foundJndiNames) { %>
                    <li><span class="code"><%= h(name) %></span></li>
                    <% } %>
                </ul>
            <% } else { %>
                <p>JNDI 컨텍스트를 자동으로 탐색할 수 없습니다. 위의 폼에서 직접 JNDI 이름을 입력하세요.</p>
            <% } %>
        </div>
        
        <!-- 커넥션 풀 정보 (가능한 경우) -->
        <div class="info">
            <h3>📊 커넥션 풀 정보</h3>
            <div class="warning">
                <p><strong>참고:</strong> 커넥션 풀 상세 정보는 WAS 관리 콘솔에서 확인하세요.</p>
                <ul>
                    <li><strong>WebLogic:</strong> Administration Console → Services → Data Sources</li>
                    <li><strong>Tomcat:</strong> context.xml 또는 server.xml 확인</li>
                    <li><strong>JBoss:</strong> Administration Console 또는 standalone.xml 확인</li>
                </ul>
            </div>
        </div>
        
        <div style="margin-top: 20px;">
            <a href="index.jsp" class="btn">메인으로 돌아가기</a>
            <a href="connection_pool.jsp" class="btn">커넥션 풀 고갈 테스트</a>
        </div>
    </div>
</body>
</html>
