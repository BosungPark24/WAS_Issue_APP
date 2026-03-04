<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>세션 누수 테스트</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; background-color: #f5f5f5; }
        .container { max-width: 800px; margin: 0 auto; background: white; padding: 20px; border-radius: 8px; }
        .warning { background-color: #ffebee; border-left: 4px solid #f44336; padding: 15px; margin: 20px 0; }
        .info { background-color: #e3f2fd; padding: 10px; margin: 10px 0; border-radius: 4px; }
        .success { background-color: #e8f5e9; padding: 10px; margin: 10px 0; border-radius: 4px; }
        .btn { display: inline-block; padding: 10px 20px; background-color: #2196F3; color: white; text-decoration: none; border-radius: 4px; margin: 5px; }
        .btn-danger { background-color: #f44336; }
        input[type="text"] { width: 300px; padding: 8px; margin: 5px 0; }
    </style>
</head>
<body>
    <div class="container">
        <h1>세션 누수 테스트</h1>
        
        <div class="warning">
            <strong>⚠️ 경고:</strong> 이 테스트는 세션에 대용량 데이터를 저장하여 세션 누수를 재현합니다.
        </div>
        
        <%
            String action = request.getParameter("action");
            String sizeMB = request.getParameter("sizeMB");
            
            if ("add".equals(action)) {
                int mb = 1;
                if (sizeMB != null && !sizeMB.isEmpty()) {
                    try {
                        mb = Integer.parseInt(sizeMB);
                    } catch (NumberFormatException e) {
                        mb = 1;
                    }
                }
                
                // 세션에 대용량 데이터 저장
                byte[] largeData = new byte[mb * 1024 * 1024];
                Arrays.fill(largeData, (byte) 1);
                
                @SuppressWarnings("unchecked")
                List<byte[]> sessionData = (List<byte[]>) session.getAttribute("leak_data");
                if (sessionData == null) {
                    sessionData = new ArrayList<byte[]>();
                    session.setAttribute("leak_data", sessionData);
                }
                
                sessionData.add(largeData);
                
                int totalMB = sessionData.size() * mb;
                
                out.println("<div class='success'>");
                out.println("<h3>세션에 데이터 추가됨</h3>");
                out.println("<p><strong>추가된 크기:</strong> " + mb + " MB</p>");
                out.println("<p><strong>세션 총 크기:</strong> " + totalMB + " MB</p>");
                out.println("<p><strong>세션 ID:</strong> " + session.getId() + "</p>");
                out.println("</div>");
            } else if ("clear".equals(action)) {
                session.removeAttribute("leak_data");
                out.println("<div class='success'>세션 데이터가 삭제되었습니다.</div>");
            }
            
            // 현재 세션 상태 표시
            @SuppressWarnings("unchecked")
            List<byte[]> sessionData = (List<byte[]>) session.getAttribute("leak_data");
            if (sessionData != null && !sessionData.isEmpty()) {
                int totalMB = sessionData.size() * (sessionData.get(0).length / 1024 / 1024);
                out.println("<div class='info'>");
                out.println("<h3>현재 세션 상태</h3>");
                out.println("<p><strong>저장된 데이터 블록 수:</strong> " + sessionData.size() + "</p>");
                out.println("<p><strong>총 세션 크기:</strong> " + totalMB + " MB</p>");
                out.println("<p><strong>세션 생성 시간:</strong> " + new Date(session.getCreationTime()) + "</p>");
                out.println("<p><strong>마지막 접근 시간:</strong> " + new Date(session.getLastAccessedTime()) + "</p>");
                out.println("</div>");
            }
        %>
        
        <div class="info">
            <h3>세션 누수 테스트</h3>
            <p>세션에 대용량 데이터를 반복적으로 저장하여 세션 메모리 누수를 재현합니다.</p>
            <p><strong>현재 세션 ID:</strong> <%= session.getId() %></p>
        </div>
        
        <form method="post">
            <input type="hidden" name="action" value="add">
            <p>
                <label>추가할 데이터 크기 (MB):</label><br>
                <input type="text" name="sizeMB" value="<%= sizeMB != null ? sizeMB : "10" %>">
            </p>
            <button type="submit" class="btn btn-danger">세션에 데이터 추가</button>
        </form>
        
        <% if (sessionData != null && !sessionData.isEmpty()) { %>
        <form method="post" style="margin-top: 20px;">
            <input type="hidden" name="action" value="clear">
            <button type="submit" class="btn">세션 데이터 삭제</button>
        </form>
        <% } %>
        
        <a href="index.jsp" class="btn">메인으로 돌아가기</a>
    </div>
</body>
</html>
