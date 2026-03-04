<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<%@ page import="java.util.concurrent.locks.*" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>데드락 시뮬레이션</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; background-color: #f5f5f5; }
        .container { max-width: 800px; margin: 0 auto; background: white; padding: 20px; border-radius: 8px; }
        .warning { background-color: #ffebee; border-left: 4px solid #f44336; padding: 15px; margin: 20px 0; }
        .info { background-color: #e3f2fd; padding: 10px; margin: 10px 0; border-radius: 4px; }
        .success { background-color: #e8f5e9; padding: 10px; margin: 10px 0; border-radius: 4px; }
        .btn { display: inline-block; padding: 10px 20px; background-color: #2196F3; color: white; text-decoration: none; border-radius: 4px; margin: 5px; }
        .btn-danger { background-color: #f44336; }
    </style>
</head>
<body>
    <div class="container">
        <h1>데드락 시뮬레이션</h1>

        <div class="warning">
            <strong>주의:</strong> 이 테스트는 서로 반대 순서로 락을 획득하여 데드락 상황을 재현합니다.
        </div>

        <%
            String action = request.getParameter("action");

            @SuppressWarnings("unchecked")
            List<Thread> deadlockThreads = (List<Thread>) application.getAttribute("deadlock_threads");
            if (deadlockThreads == null) {
                synchronized (application) {
                    deadlockThreads = (List<Thread>) application.getAttribute("deadlock_threads");
                    if (deadlockThreads == null) {
                        deadlockThreads = Collections.synchronizedList(new ArrayList<Thread>());
                        application.setAttribute("deadlock_threads", deadlockThreads);
                    }
                }
            }

            if ("test".equals(action)) {
                final ReentrantLock lock1 = new ReentrantLock();
                final ReentrantLock lock2 = new ReentrantLock();

                Thread thread1 = new Thread(new Runnable() {
                    @Override
                    public void run() {
                        boolean locked1 = false;
                        boolean locked2 = false;
                        try {
                            lock1.lockInterruptibly();
                            locked1 = true;
                            Thread.sleep(1000);
                            lock2.lockInterruptibly();
                            locked2 = true;
                        } catch (InterruptedException e) {
                            Thread.currentThread().interrupt();
                        } finally {
                            if (locked2 && lock2.isHeldByCurrentThread()) lock2.unlock();
                            if (locked1 && lock1.isHeldByCurrentThread()) lock1.unlock();
                        }
                    }
                });
                thread1.setName("DeadlockThread-1");
                thread1.setDaemon(true);

                Thread thread2 = new Thread(new Runnable() {
                    @Override
                    public void run() {
                        boolean locked1 = false;
                        boolean locked2 = false;
                        try {
                            lock2.lockInterruptibly();
                            locked2 = true;
                            Thread.sleep(1000);
                            lock1.lockInterruptibly();
                            locked1 = true;
                        } catch (InterruptedException e) {
                            Thread.currentThread().interrupt();
                        } finally {
                            if (locked1 && lock1.isHeldByCurrentThread()) lock1.unlock();
                            if (locked2 && lock2.isHeldByCurrentThread()) lock2.unlock();
                        }
                    }
                });
                thread2.setName("DeadlockThread-2");
                thread2.setDaemon(true);

                thread1.start();
                thread2.start();

                deadlockThreads.add(thread1);
                deadlockThreads.add(thread2);

                try {
                    Thread.sleep(2000);
                } catch (InterruptedException e) {
                    Thread.currentThread().interrupt();
                }

                boolean thread1Alive = thread1.isAlive();
                boolean thread2Alive = thread2.isAlive();

                out.println("<div class='success'>");
                out.println("<h3>데드락 시뮬레이션 결과</h3>");
                out.println("<p><strong>스레드 1 상태:</strong> " + (thread1Alive ? "블로킹됨(또는 대기 중)" : "종료됨") + "</p>");
                out.println("<p><strong>스레드 2 상태:</strong> " + (thread2Alive ? "블로킹됨(또는 대기 중)" : "종료됨") + "</p>");
                out.println("<p><strong>중단 방식:</strong> stop 버튼은 interrupt를 보내며 lockInterruptibly() 대기를 해제합니다.</p>");
                out.println("</div>");

            } else if ("stop".equals(action)) {
                int interrupted = 0;
                synchronized (deadlockThreads) {
                    for (Thread t : deadlockThreads) {
                        if (t != null && t.isAlive()) {
                            t.interrupt();
                            interrupted++;
                        }
                    }
                    deadlockThreads.clear();
                }
                application.removeAttribute("deadlock_threads");
                out.println("<div class='success'>" + interrupted + "개의 데드락 스레드에 interrupt를 전송했습니다.</div>");
            }

            if (deadlockThreads != null && !deadlockThreads.isEmpty()) {
                int alive = 0;
                synchronized (deadlockThreads) {
                    for (Thread t : deadlockThreads) {
                        if (t != null && t.isAlive()) alive++;
                    }
                }
                out.println("<div class='info'>");
                out.println("<h3>현재 데드락 스레드 상태</h3>");
                out.println("<p><strong>활성 스레드 수:</strong> " + alive + "</p>");
                out.println("</div>");
            }
        %>

        <div class="info">
            <h3>시나리오</h3>
            <ul>
                <li>스레드 1: lock1 획득 후 lock2 대기</li>
                <li>스레드 2: lock2 획득 후 lock1 대기</li>
                <li>stop 시 interrupt로 대기 해제</li>
            </ul>
        </div>

        <form method="post">
            <input type="hidden" name="action" value="test">
            <button type="submit" class="btn btn-danger">데드락 시뮬레이션 시작</button>
        </form>

        <% if (application.getAttribute("deadlock_threads") != null) { %>
        <form method="post" style="margin-top: 20px;">
            <input type="hidden" name="action" value="stop">
            <button type="submit" class="btn">데드락 스레드 중단</button>
        </form>
        <% } %>

        <a href="index.jsp" class="btn">메인으로 돌아가기</a>
    </div>
</body>
</html>
