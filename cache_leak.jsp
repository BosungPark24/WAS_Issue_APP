<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>캐시 누수 테스트</title>
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
        <h1>캐시 누수 테스트</h1>
        
        <div class="warning">
            <strong>⚠️ 경고:</strong> 이 테스트는 정적 캐시에 무한정 데이터를 추가하여 메모리 누수를 재현합니다.
        </div>
        
        <%
            // 정적 캐시 (애플리케이션 전체에서 공유)
            @SuppressWarnings("unchecked")
            Map<String, byte[]> staticCache = (Map<String, byte[]>) application.getAttribute("static_cache");
            if (staticCache == null) {
                synchronized (application) {
                    staticCache = (Map<String, byte[]>) application.getAttribute("static_cache");
                    if (staticCache == null) {
                        staticCache = Collections.synchronizedMap(new HashMap<String, byte[]>());
                        application.setAttribute("static_cache", staticCache);
                    }
                }
            }
            
            String action = request.getParameter("action");
            String sizeMB = request.getParameter("sizeMB");
            String count = request.getParameter("count");
            
            if ("add".equals(action)) {
                int mb = 1;
                int itemCount = 10;
                
                if (sizeMB != null && !sizeMB.isEmpty()) {
                    try {
                        mb = Integer.parseInt(sizeMB);
                    } catch (NumberFormatException e) {
                        mb = 1;
                    }
                }
                
                if (count != null && !count.isEmpty()) {
                    try {
                        itemCount = Integer.parseInt(count);
                    } catch (NumberFormatException e) {
                        itemCount = 10;
                    }
                }
                
                int added = 0;
                try {
                    for (int i = 0; i < itemCount; i++) {
                        String key = "cache_item_" + System.currentTimeMillis() + "_" + i;
                        byte[] data = new byte[mb * 1024 * 1024];
                        Arrays.fill(data, (byte) (i % 256));
                        staticCache.put(key, data);
                        added++;
                    }
                    
                    int totalMB = staticCache.size() * mb;
                    
                    out.println("<div class='success'>");
                    out.println("<h3>캐시에 데이터 추가됨</h3>");
                    out.println("<p><strong>추가된 항목:</strong> " + added + "개</p>");
                    out.println("<p><strong>각 항목 크기:</strong> " + mb + " MB</p>");
                    out.println("<p><strong>캐시 총 크기:</strong> " + totalMB + " MB</p>");
                    out.println("</div>");
                } catch (OutOfMemoryError e) {
                    out.println("<div class='warning'>");
                    out.println("<h3>OutOfMemoryError 발생!</h3>");
                    out.println("<p><strong>에러:</strong> " + e.getMessage() + "</p>");
                    out.println("<p><strong>추가된 항목:</strong> " + added + "개</p>");
                    out.println("</div>");
                }
            } else if ("clear".equals(action)) {
                staticCache.clear();
                out.println("<div class='success'>캐시가 비워졌습니다.</div>");
            }
            
            // 현재 캐시 상태
            if (!staticCache.isEmpty()) {
                int sampleSize = 0;
                if (!staticCache.isEmpty()) {
                    byte[] sample = staticCache.values().iterator().next();
                    sampleSize = sample.length / 1024 / 1024;
                }
                int totalMB = staticCache.size() * sampleSize;
                
                out.println("<div class='info'>");
                out.println("<h3>현재 캐시 상태</h3>");
                out.println("<p><strong>캐시 항목 수:</strong> " + staticCache.size() + "</p>");
                out.println("<p><strong>각 항목 크기:</strong> " + sampleSize + " MB</p>");
                out.println("<p><strong>캐시 총 크기:</strong> " + totalMB + " MB</p>");
                out.println("<p><strong>주의:</strong> 이 캐시는 애플리케이션 전체에서 공유되며, 서버 재시작 전까지 유지됩니다.</p>");
                out.println("</div>");
            }
        %>
        
        <div class="info">
            <h3>캐시 누수 테스트</h3>
            <p>정적 캐시에 무한정 데이터를 추가하여 메모리 누수를 재현합니다.</p>
            <p>이 캐시는 애플리케이션 컨텍스트에 저장되어 서버 재시작 전까지 유지됩니다.</p>
        </div>
        
        <form method="post">
            <input type="hidden" name="action" value="add">
            <p>
                <label>각 항목 크기 (MB):</label><br>
                <input type="text" name="sizeMB" value="<%= sizeMB != null ? sizeMB : "5" %>">
            </p>
            <p>
                <label>추가할 항목 수:</label><br>
                <input type="text" name="count" value="<%= count != null ? count : "20" %>">
            </p>
            <button type="submit" class="btn btn-danger">캐시에 데이터 추가</button>
        </form>
        
        <% if (!staticCache.isEmpty()) { %>
        <form method="post" style="margin-top: 20px;">
            <input type="hidden" name="action" value="clear">
            <button type="submit" class="btn">캐시 비우기</button>
        </form>
        <% } %>
        
        <a href="index.jsp" class="btn">메인으로 돌아가기</a>
    </div>
</body>
</html>
