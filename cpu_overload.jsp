<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>CPU 과부하 테스트</title>
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
        <h1>CPU 과부하 테스트</h1>
        
        <div class="warning">
            <strong>⚠️ 경고:</strong> 이 테스트는 무한 루프를 통한 CPU 100% 사용을 재현합니다.
            서버 성능에 심각한 영향을 줄 수 있습니다.
        </div>
        
        <%
            String action = request.getParameter("action");
            String duration = request.getParameter("duration");
            String threadCount = request.getParameter("threadCount");
            
            @SuppressWarnings("unchecked")
            List<Thread> cpuThreads = (List<Thread>) application.getAttribute("cpu_threads");
            if (cpuThreads == null) {
                cpuThreads = Collections.synchronizedList(new ArrayList<Thread>());
                application.setAttribute("cpu_threads", cpuThreads);
            }
            
            if ("test".equals(action)) {
                int count = Runtime.getRuntime().availableProcessors(); // CPU 코어 수만큼
                int seconds = 30;
                
                if (threadCount != null && !threadCount.isEmpty()) {
                    try {
                        count = Integer.parseInt(threadCount);
                    } catch (NumberFormatException e) {
                        count = Runtime.getRuntime().availableProcessors();
                    }
                }
                
                if (duration != null && !duration.isEmpty()) {
                    try {
                        seconds = Integer.parseInt(duration);
                    } catch (NumberFormatException e) {
                        seconds = 30;
                    }
                }
                
                final int finalSeconds = seconds;
                
                out.println("<div class='info'>CPU 과부하 스레드 생성 시작... (목표: " + count + "개, 지속 시간: " + seconds + "초)</div>");
                out.flush();
                
                for (int i = 0; i < count; i++) {
                    final int threadNum = i + 1;
                    Thread thread = new Thread(new Runnable() {
                        @Override
                        public void run() {
                            long endTime = System.currentTimeMillis() + (finalSeconds * 1000);
                            // CPU 집약적인 무한 루프
                            while (System.currentTimeMillis() < endTime && !Thread.currentThread().isInterrupted()) {
                                // CPU를 최대한 사용하는 계산
                                double result = 0;
                                for (int j = 0; j < 1000000; j++) {
                                    if (Thread.currentThread().isInterrupted()) {
                                        return;
                                    }
                                    result += Math.sqrt(j) * Math.sin(j);
                                }
                            }
                        }
                    });
                    thread.setName("CPUThread-" + threadNum);
                    thread.setDaemon(true);
                    thread.start();
                    cpuThreads.add(thread);
                }
                
                out.println("<div class='success'>");
                out.println("<h3>CPU 과부하 테스트 시작</h3>");
                out.println("<p><strong>생성된 스레드:</strong> " + count + "개</p>");
                out.println("<p><strong>지속 시간:</strong> " + seconds + "초</p>");
                out.println("<p><strong>CPU 코어 수:</strong> " + Runtime.getRuntime().availableProcessors() + "</p>");
                out.println("<p>각 스레드는 CPU 집약적인 계산을 수행합니다.</p>");
                out.println("</div>");
                
            } else if ("stop".equals(action)) {
                synchronized (cpuThreads) {
                    for (Thread t : cpuThreads) {
                        if (t != null && t.isAlive()) {
                            t.interrupt();
                        }
                    }
                    cpuThreads.clear();
                }
                application.removeAttribute("cpu_threads");
                out.println("<div class='success'>CPU 과부하 스레드가 중단되었습니다.</div>");
            }
            
            // 현재 상태
            if (!cpuThreads.isEmpty()) {
                int alive = 0;
                synchronized (cpuThreads) {
                    for (Thread t : cpuThreads) {
                        if (t != null && t.isAlive()) {
                            alive++;
                        }
                    }
                }
                out.println("<div class='info'>");
                out.println("<h3>현재 CPU 과부하 스레드 상태</h3>");
                out.println("<p><strong>활성 스레드 수:</strong> " + alive + "</p>");
                out.println("<p><strong>주의:</strong> 이 스레드들은 CPU를 최대한 사용하고 있습니다.</p>");
                out.println("</div>");
            }
        %>
        
        <div class="info">
            <h3>CPU 과부하 테스트</h3>
            <p>무한 루프를 통한 CPU 100% 사용을 재현합니다.</p>
            <p><strong>현재 CPU 코어 수:</strong> <%= Runtime.getRuntime().availableProcessors() %></p>
            <p><strong>주의:</strong> CPU 코어 수만큼 스레드를 생성하면 CPU 사용률이 100%에 가까워집니다.</p>
        </div>
        
        <form method="post">
            <input type="hidden" name="action" value="test">
            <p>
                <label>생성할 스레드 수 (기본값: CPU 코어 수):</label><br>
                <input type="text" name="threadCount" value="<%= threadCount != null ? threadCount : String.valueOf(Runtime.getRuntime().availableProcessors()) %>">
            </p>
            <p>
                <label>지속 시간 (초):</label><br>
                <input type="text" name="duration" value="<%= duration != null ? duration : "30" %>">
            </p>
            <button type="submit" class="btn btn-danger">CPU 과부하 테스트 시작</button>
        </form>
        
        <% if (!cpuThreads.isEmpty()) { %>
        <form method="post" style="margin-top: 20px;">
            <input type="hidden" name="action" value="stop">
            <button type="submit" class="btn">모든 스레드 중단</button>
        </form>
        <% } %>
        
        <a href="index.jsp" class="btn">메인으로 돌아가기</a>
    </div>
</body>
</html>
