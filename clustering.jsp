<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<%@ page import="java.net.*" %>
<%@ page import="javax.servlet.http.Cookie" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>클러스터링 테스트</title>
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
        .btn { display: inline-block; padding: 10px 20px; background-color: #2196F3; color: white; text-decoration: none; border-radius: 4px; margin: 5px; }
        .btn-success { background-color: #4CAF50; }
        .btn-warning { background-color: #ff9800; }
        .code { background-color: #f5f5f5; padding: 10px; border-radius: 4px; font-family: monospace; margin: 10px 0; overflow-x: auto; }
        .cookie-badge { display: inline-block; padding: 3px 8px; background-color: #4CAF50; color: white; border-radius: 3px; font-size: 12px; margin: 2px; }
        .cookie-missing { background-color: #f44336; }
    </style>
</head>
<body>
    <div class="container">
        <h1>🔗 클러스터링 테스트</h1>
        
        <div class="info">
            <h3>클러스터링 정보 확인</h3>
            <p>이 페이지는 클러스터 환경에서 세션 어피니티, 쿠키, 서버 정보를 확인할 수 있습니다.</p>
        </div>
        
        <%
            String action = request.getParameter("action");
            String sessionData = request.getParameter("sessionData");
            
            // 세션 데이터 저장/조회
            if ("set".equals(action) && sessionData != null) {
                session.setAttribute("test_data", sessionData);
                session.setAttribute("test_time", new Date().toString());
                session.setAttribute("test_server", request.getServerName() + ":" + request.getServerPort());
            }
            
            if ("clear".equals(action)) {
                session.removeAttribute("test_data");
                session.removeAttribute("test_time");
                session.removeAttribute("test_server");
            }
        %>
        
        <!-- 서버 정보 -->
        <div class="info">
            <h3>📊 서버 정보</h3>
            <table>
                <tr>
                    <th>항목</th>
                    <th>값</th>
                </tr>
                <tr>
                    <td>서버 이름</td>
                    <td><%= request.getServerName() %></td>
                </tr>
                <tr>
                    <td>서버 포트</td>
                    <td><%= request.getServerPort() %></td>
                </tr>
                <tr>
                    <td>로컬 주소</td>
                    <td><%= request.getLocalAddr() %>:<%= request.getLocalPort() %></td>
                </tr>
                <tr>
                    <td>원격 주소</td>
                    <td><%= request.getRemoteAddr() %>:<%= request.getRemotePort() %></td>
                </tr>
                <tr>
                    <td>요청 URL</td>
                    <td><%= request.getRequestURL() %></td>
                </tr>
                <tr>
                    <td>요청 URI</td>
                    <td><%= request.getRequestURI() %></td>
                </tr>
                <tr>
                    <td>프로토콜</td>
                    <td><%= request.getProtocol() %></td>
                </tr>
                <tr>
                    <td>서버 정보</td>
                    <td><%= application.getServerInfo() %></td>
                </tr>
                <tr>
                    <td>서블릿 컨텍스트</td>
                    <td><%= application.getServletContextName() != null ? application.getServletContextName() : application.getContextPath() %></td>
                </tr>
            </table>
        </div>
        
        <!-- 세션 정보 -->
        <div class="info">
            <h3>🔐 세션 정보</h3>
            <table>
                <tr>
                    <th>항목</th>
                    <th>값</th>
                </tr>
                <tr>
                    <td>세션 ID</td>
                    <td><span class="code"><%= session.getId() %></span></td>
                </tr>
                <tr>
                    <td>세션 생성 시간</td>
                    <td><%= new Date(session.getCreationTime()) %></td>
                </tr>
                <tr>
                    <td>마지막 접근 시간</td>
                    <td><%= new Date(session.getLastAccessedTime()) %></td>
                </tr>
                <tr>
                    <td>세션 유효 시간 (초)</td>
                    <td><%= session.getMaxInactiveInterval() %></td>
                </tr>
                <tr>
                    <td>새로운 세션 여부</td>
                    <td><%= session.isNew() ? "예" : "아니오" %></td>
                </tr>
                <tr>
                    <td>세션 속성 개수</td>
                    <td>
                        <%
                            int attrCount = 0;
                            Enumeration<String> attrNames = session.getAttributeNames();
                            while (attrNames.hasMoreElements()) {
                                attrNames.nextElement();
                                attrCount++;
                            }
                        %>
                        <%= attrCount %>
                    </td>
                </tr>
            </table>
        </div>
        
        <!-- 쿠키 정보 -->
        <div class="info">
            <h3>🍪 쿠키 정보</h3>
            <%
                Cookie[] cookies = request.getCookies();
                Map<String, String> cookieMap = new HashMap<String, String>();
                boolean hasJSessionId = false;
                boolean hasWLCookie = false;
                boolean hasJSESSIONID = false;
                
                if (cookies != null) {
                    for (Cookie cookie : cookies) {
                        cookieMap.put(cookie.getName(), cookie.getValue());
                        if ("JSESSIONID".equals(cookie.getName())) {
                            hasJSESSIONID = true;
                        }
                        if ("JSESSIONID".equals(cookie.getName())) {
                            hasJSessionId = true;
                        }
                        if (cookie.getName().toUpperCase().contains("WLCOOKIE") || 
                            cookie.getName().toUpperCase().contains("WEBLOGIC")) {
                            hasWLCookie = true;
                        }
                    }
                }
            %>
            
            <table>
                <tr>
                    <th>쿠키 이름</th>
                    <th>쿠키 값</th>
                    <th>상태</th>
                </tr>
                <%
                    if (cookies != null && cookies.length > 0) {
                        for (Cookie cookie : cookies) {
                            String cookieName = cookie.getName();
                            String cookieValue = cookie.getValue();
                            String status = "";
                            
                            if ("JSESSIONID".equals(cookieName) || "JSESSIONID".equals(cookieName)) {
                                status = "<span class='cookie-badge'>세션 쿠키</span>";
                            } else if (cookieName.toUpperCase().contains("WLCOOKIE") || 
                                      cookieName.toUpperCase().contains("WEBLOGIC")) {
                                status = "<span class='cookie-badge'>WebLogic 쿠키</span>";
                            }
                %>
                <tr>
                    <td><strong><%= cookieName %></strong></td>
                    <td><span class="code"><%= cookieValue.length() > 50 ? cookieValue.substring(0, 50) + "..." : cookieValue %></span></td>
                    <td><%= status %></td>
                </tr>
                <%
                        }
                    } else {
                %>
                <tr>
                    <td colspan="3">쿠키가 없습니다.</td>
                </tr>
                <%
                    }
                %>
            </table>
            
            <div style="margin-top: 15px;">
                <h4>클러스터링 쿠키 확인</h4>
                <p>
                    <% if (hasJSESSIONID || hasJSessionId) { %>
                        <span class="cookie-badge">JSESSIONID</span> 발견됨
                    <% } else { %>
                        <span class="cookie-badge cookie-missing">JSESSIONID</span> 없음
                    <% } %>
                    
                    <% if (hasWLCookie) { %>
                        <span class="cookie-badge">WLCookie</span> 발견됨
                    <% } else { %>
                        <span class="cookie-badge cookie-missing">WLCookie</span> 없음 (WebLogic 클러스터 미설정 또는 단일 서버)
                    <% } %>
                </p>
            </div>
        </div>
        
        <!-- 세션 데이터 테스트 -->
        <div class="info">
            <h3>💾 세션 데이터 테스트</h3>
            <%
                String testData = (String) session.getAttribute("test_data");
                String testTime = (String) session.getAttribute("test_time");
                String testServer = (String) session.getAttribute("test_server");
            %>
            
            <% if (testData != null) { %>
                <div class="success">
                    <h4>저장된 세션 데이터</h4>
                    <table>
                        <tr>
                            <th>항목</th>
                            <th>값</th>
                        </tr>
                        <tr>
                            <td>테스트 데이터</td>
                            <td><%= testData %></td>
                        </tr>
                        <tr>
                            <td>저장 시간</td>
                            <td><%= testTime %></td>
                        </tr>
                        <tr>
                            <td>저장 서버</td>
                            <td><%= testServer %></td>
                        </tr>
                        <tr>
                            <td>현재 서버</td>
                            <td><%= request.getServerName() + ":" + request.getServerPort() %></td>
                        </tr>
                        <tr>
                            <td>서버 일치 여부</td>
                            <td>
                                <% 
                                    boolean serverMatch = (testServer != null && 
                                        testServer.equals(request.getServerName() + ":" + request.getServerPort()));
                                %>
                                <%= serverMatch ? 
                                    "<span class='cookie-badge'>일치</span>" : 
                                    "<span class='cookie-badge cookie-missing'>불일치 (세션 복제 확인 필요)</span>" %>
                            </td>
                        </tr>
                    </table>
                </div>
            <% } else { %>
                <div class="warning">
                    <p>세션에 테스트 데이터가 없습니다. 아래에서 데이터를 저장하세요.</p>
                </div>
            <% } %>
            
            <form method="post" style="margin-top: 15px;">
                <input type="hidden" name="action" value="set">
                <p>
                    <label>세션에 저장할 테스트 데이터:</label><br>
                    <input type="text" name="sessionData" value="<%= testData != null ? testData : "클러스터링 테스트 데이터 " + System.currentTimeMillis() %>" 
                           style="width: 400px; padding: 8px;">
                </p>
                <button type="submit" class="btn btn-success">세션에 데이터 저장</button>
            </form>
            
            <% if (testData != null) { %>
            <form method="post" style="margin-top: 10px;">
                <input type="hidden" name="action" value="clear">
                <button type="submit" class="btn btn-warning">세션 데이터 삭제</button>
            </form>
            <% } %>
        </div>
        
        <!-- 클러스터링 진단 -->
        <div class="info">
            <h3>🔍 클러스터링 진단</h3>
            <%
                boolean isClustered = false;
                String clusterInfo = "";
                
                // WebLogic 클러스터 확인
                try {
                    Object clusterName = application.getAttribute("weblogic.cluster.name");
                    if (clusterName != null) {
                        isClustered = true;
                        clusterInfo = "WebLogic 클러스터: " + clusterName.toString();
                    }
                } catch (Exception e) {
                    // 무시
                }
                
                // 쿠키 기반 클러스터링 확인
                if (hasWLCookie) {
                    isClustered = true;
                    if (clusterInfo.isEmpty()) {
                        clusterInfo = "WebLogic 클러스터 (쿠키 기반 확인)";
                    }
                }
                
                // 세션 복제 확인 (여러 서버에서 같은 세션 ID로 접근 가능한지)
                // 실제로는 다른 서버에서 접근해야 확인 가능
            %>
            
            <table>
                <tr>
                    <th>항목</th>
                    <th>상태</th>
                </tr>
                <tr>
                    <td>클러스터 환경</td>
                    <td>
                        <%= isClustered ? 
                            "<span class='cookie-badge'>클러스터 모드</span>" : 
                            "<span class='cookie-badge cookie-missing'>단일 서버 모드</span>" %>
                    </td>
                </tr>
                <tr>
                    <td>클러스터 정보</td>
                    <td><%= clusterInfo.isEmpty() ? "정보 없음" : clusterInfo %></td>
                </tr>
                <tr>
                    <td>세션 어피니티</td>
                    <td>
                        <%= (hasJSESSIONID || hasJSessionId || hasWLCookie) ? 
                            "<span class='cookie-badge'>활성화됨</span>" : 
                            "<span class='cookie-badge cookie-missing'>비활성화됨</span>" %>
                    </td>
                </tr>
                <tr>
                    <td>세션 복제 확인</td>
                    <td>
                        <div class="warning">
                            <p>세션 복제를 확인하려면:</p>
                            <ol>
                                <li>이 페이지에서 세션 데이터를 저장</li>
                                <li>다른 서버 노드에서 같은 세션으로 접근</li>
                                <li>저장한 데이터가 보이는지 확인</li>
                            </ol>
                        </div>
                    </td>
                </tr>
            </table>
        </div>
        
        <!-- HTTP 헤더 정보 -->
        <div class="info">
            <h3>📋 HTTP 헤더 정보</h3>
            <table>
                <tr>
                    <th>헤더 이름</th>
                    <th>값</th>
                </tr>
                <%
                    Enumeration<String> headerNames = request.getHeaderNames();
                    while (headerNames.hasMoreElements()) {
                        String headerName = headerNames.nextElement();
                        String headerValue = request.getHeader(headerName);
                %>
                <tr>
                    <td><strong><%= headerName %></strong></td>
                    <td><span class="code"><%= headerValue %></span></td>
                </tr>
                <%
                    }
                %>
            </table>
        </div>
        
        <div style="margin-top: 20px;">
            <a href="index.jsp" class="btn">메인으로 돌아가기</a>
            <button onclick="location.reload()" class="btn">페이지 새로고침</button>
        </div>
    </div>
</body>
</html>
