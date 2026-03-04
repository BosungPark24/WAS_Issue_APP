<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<%@ page import="java.util.concurrent.*" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>스레드 풀 고갈 테스트</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; background-color: #f5f5f5; }
        .container { max-width: 800px; margin: 0 auto; background: white; padding: 20px; border-radius: 8px; }
        .warning { background-color: #ffebee; border-left: 4px solid #f44336; padding: 15px; margin: 20px 0; }
        .info { background-color: #e3f2fd; padding: 10px; margin: 10px 0; border-radius: 4px; }
        .success { background-color: #e8f5e9; padding: 10px; margin: 10px 0; border-radius: 4px; }
        .error { background-color: #ffebee; padding: 10px; margin: 10px 0; border-radius: 4px; }
        .btn { display: inline-block; padding: 10px 20px; background-color: #2196F3; color: white; text-decoration: none; border-radius: 4px; margin: 5px; }
        .btn-danger { background-color: #f44336; }
        input[type="text"] { width: 300px; padding: 8px; margin: 5px 0; }
    </style>
</head>
<body>
    <div class="container">
        <h1>스레드 풀 고갈 테스트</h1>
        
        <div class="warning">
            <strong>⚠️ 경고:</strong> 이 테스트는 대량의 스레드를 생성하여 스레드 풀 고갈을 재현합니다.
            서버 성능에 심각한 영향을 줄 수 있습니다.
        </div>
        
        <%
            String action = request.getParameter("action");
            String threadCount = request.getParameter("threadCount");
            String sleepSeconds = request.getParameter("sleepSeconds");
            
            if ("test".equals(action)) {
                int count = 100;
                int sleep = 60; // 기본 60초
                final int sleepMillis;
                
                if (threadCount != null && !threadCount.isEmpty()) {
                    try {
                        count = Integer.parseInt(threadCount);
                    } catch (NumberFormatException e) {
                        count = 100;
                    }
                }
                
                if (sleepSeconds != null && !sleepSeconds.isEmpty()) {
                    try {
                        sleep = Integer.parseInt(sleepSeconds);
                    } catch (NumberFormatException e) {
                        sleep = 60;
                    }
                }

                sleepMillis = sleep * 1000;
                
                @SuppressWarnings("unchecked")
                List<Thread> threads = (List<Thread>) application.getAttribute("test_threads");
                if (threads == null) {
                    synchronized (application) {
                        threads = (List<Thread>) application.getAttribute("test_threads");
                        if (threads == null) {
                            threads = Collections.synchronizedList(new ArrayList<Thread>());
                            application.setAttribute("test_threads", threads);
                        }
                    }
                }
                
                int created = 0;
                int failed = 0;
                
                out.println("<div class='info'>스레드 생성 시작... (목표: " + count + "개, 대기 시간: " + sleep + "초)</div>");
                out.flush();
                
                for (int i = 0; i < count; i++) {
                    try {
                        final int threadNum = i + 1;
                        Thread thread = new Thread(new Runnable() {
                            @Override
                            public void run() {
                                try {
                                    Thread.sleep(sleepMillis);
                                } catch (InterruptedException e) {
                                    Thread.currentThread().interrupt();
                                }
                            }
                        });
                        thread.setName("TestThread-" + threadNum);
                        thread.setDaemon(true);
                        thread.start();
                        threads.add(thread);
                        created++;
                        
                        if (created % 10 == 0) {
                            out.println("<div class='info'>" + created + "개 스레드 생성됨...</div>");
                            out.flush();
                        }
                    } catch (OutOfMemoryError e) {
                        failed++;
                        out.println("<div class='error'>스레드 생성 실패 (OOME): " + e.getMessage() + "</div>");
                        break;
                    } catch (Exception e) {
                        failed++;
                        if (e.getMessage() != null && (e.getMessage().contains("thread") || e.getMessage().contains("resource"))) {
                            out.println("<div class='error'>스레드 생성 실패: " + e.getMessage() + "</div>");
                            break;
                        }
                    }
                }
                
                out.println("<div class='success'>");
                out.println("<h3>테스트 결과</h3>");
                out.println("<p><strong>생성된 스레드:</strong> " + created + "개</p>");
                out.println("<p><strong>실패한 스레드:</strong> " + failed + "개</p>");
                out.println("<p><strong>현재 활성 스레드 수:</strong> " + Thread.activeCount() + "</p>");
                out.println("</div>");
                
            } else if ("stop".equals(action)) {
                @SuppressWarnings("unchecked")
                List<Thread> threads = (List<Thread>) application.getAttribute("test_threads");
                if (threads != null) {
                    int interrupted = 0;
                    synchronized (threads) {
                        for (Thread thread : threads) {
                            if (thread != null && thread.isAlive()) {
                                thread.interrupt();
                                interrupted++;
                            }
                        }
                        threads.clear();
                    }
                    application.removeAttribute("test_threads");
                    out.println("<div class='success'>" + interrupted + "개의 스레드가 중단되었습니다.</div>");
                }
            }
            
            // 현재 스레드 상태
            @SuppressWarnings("unchecked")
            List<Thread> threads = (List<Thread>) application.getAttribute("test_threads");
            if (threads != null && !threads.isEmpty()) {
                int alive = 0;
                synchronized (threads) {
                    for (Thread t : threads) {
                        if (t != null && t.isAlive()) {
                            alive++;
                        }
                    }
                }
                out.println("<div class='info'>");
                out.println("<h3>현재 스레드 상태</h3>");
                out.println("<p><strong>생성된 스레드 수:</strong> " + threads.size() + "</p>");
                out.println("<p><strong>활성 스레드 수:</strong> " + alive + "</p>");
                out.println("<p><strong>JVM 활성 스레드 수:</strong> " + Thread.activeCount() + "</p>");
                out.println("</div>");
            }
        %>
        
        <div class="info">
            <h3>스레드 풀 고갈 테스트</h3>
            <p>대량의 스레드를 생성하여 스레드 풀 고갈을 재현합니다.</p>
            <p><strong>현재 JVM 활성 스레드 수:</strong> <%= Thread.activeCount() %></p>
        </div>
        
        <form method="post">
            <input type="hidden" name="action" value="test">
            <p>
                <label>생성할 스레드 수:</label><br>
                <input type="text" name="threadCount" value="<%= threadCount != null ? threadCount : "200" %>">
            </p>
            <p>
                <label>각 스레드 대기 시간 (초):</label><br>
                <input type="text" name="sleepSeconds" value="<%= sleepSeconds != null ? sleepSeconds : "60" %>">
            </p>
            <button type="submit" class="btn btn-danger">스레드 생성 시작</button>
        </form>
        
        <% if (application.getAttribute("test_threads") != null) { %>
        <form method="post" style="margin-top: 20px;">
            <input type="hidden" name="action" value="stop">
            <button type="submit" class="btn">모든 스레드 중단</button>
        </form>
        <% } %>
        
        <a href="index.jsp" class="btn">메인으로 돌아가기</a>
    </div>
</body>
</html>
