<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>OOME 테스트</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; background-color: #f5f5f5; }
        .container { max-width: 800px; margin: 0 auto; background: white; padding: 20px; border-radius: 8px; }
        .warning { background-color: #ffebee; border-left: 4px solid #f44336; padding: 15px; margin: 20px 0; }
        .info { background-color: #e3f2fd; padding: 10px; margin: 10px 0; border-radius: 4px; }
        .btn { display: inline-block; padding: 10px 20px; background-color: #2196F3; color: white; text-decoration: none; border-radius: 4px; margin: 5px; }
        .btn-danger { background-color: #f44336; }
    </style>
</head>
<body>
    <div class="container">
        <h1>OutOfMemoryError (OOME) 재현 테스트</h1>
        
        <div class="warning">
            <strong>⚠️ 경고:</strong> 이 테스트는 서버의 힙 메모리를 고의로 소진시켜 OOME를 발생시킵니다. 
            서버가 다운될 수 있으니 주의하세요!
        </div>
        
        <%
            String action = request.getParameter("action");
            String memoryType = request.getParameter("type");
            
            if ("test".equals(action)) {
                Runtime runtime = Runtime.getRuntime();
                long beforeMemory = runtime.totalMemory() - runtime.freeMemory();
                
                try {
                    if ("heap".equals(memoryType)) {
                        // 힙 메모리 소진
                        List<byte[]> memoryList = new ArrayList<byte[]>();
                        int count = 0;
                        while (true) {
                            // 10MB씩 할당
                            byte[] array = new byte[10 * 1024 * 1024];
                            memoryList.add(array);
                            count++;
                            
                            if (count % 10 == 0) {
                                out.println("<div class='info'>" + (count * 10) + " MB 할당됨...</div>");
                                out.flush();
                            }
                        }
                    } else if ("permgen".equals(memoryType)) {
                        // PermGen/Metaspace 누수 시뮬레이션 (동적 클래스 로딩)
                        out.println("<div class='info'>PermGen/Metaspace 누수 테스트는 permgen_leak.jsp에서 수행하세요.</div>");
                    }
                } catch (OutOfMemoryError e) {
                    long afterMemory = runtime.totalMemory() - runtime.freeMemory();
                    out.println("<div class='warning'>");
                    out.println("<h2>OutOfMemoryError 발생!</h2>");
                    out.println("<p><strong>에러 타입:</strong> " + e.getClass().getName() + "</p>");
                    out.println("<p><strong>에러 메시지:</strong> " + e.getMessage() + "</p>");
                    out.println("<p><strong>사용 메모리 (이전):</strong> " + (beforeMemory / 1024 / 1024) + " MB</p>");
                    out.println("<p><strong>사용 메모리 (현재):</strong> " + (afterMemory / 1024 / 1024) + " MB</p>");
                    out.println("<p><strong>최대 메모리:</strong> " + (runtime.maxMemory() / 1024 / 1024) + " MB</p>");
                    out.println("</div>");
                }
            } else {
        %>
        
        <div class="info">
            <h3>테스트 옵션</h3>
            <p>힙 메모리를 고의로 소진시켜 OutOfMemoryError를 발생시킵니다.</p>
            <p><strong>현재 메모리 상태:</strong></p>
            <%
                Runtime runtime = Runtime.getRuntime();
                long totalMemory = runtime.totalMemory();
                long freeMemory = runtime.freeMemory();
                long usedMemory = totalMemory - freeMemory;
                long maxMemory = runtime.maxMemory();
            %>
            <ul>
                <li>사용 중: <%= String.format("%.2f MB", usedMemory / 1024.0 / 1024.0) %></li>
                <li>사용 가능: <%= String.format("%.2f MB", freeMemory / 1024.0 / 1024.0) %></li>
                <li>최대: <%= String.format("%.2f MB", maxMemory / 1024.0 / 1024.0) %></li>
            </ul>
        </div>
        
        <form method="post">
            <input type="hidden" name="action" value="test">
            <input type="hidden" name="type" value="heap">
            <button type="submit" class="btn btn-danger">힙 메모리 소진 테스트 시작</button>
        </form>
        
        <a href="index.jsp" class="btn">메인으로 돌아가기</a>
        
        <% } %>
    </div>
</body>
</html>
