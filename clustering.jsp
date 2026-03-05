<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>클러스터링(세션 페일오버) 테스트</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; background-color: #f5f5f5; }
        .container { max-width: 900px; margin: 0 auto; background: #fff; padding: 20px; border-radius: 8px; }
        .warning { background-color: #ffebee; border-left: 4px solid #f44336; padding: 15px; margin: 20px 0; }
        .info { background-color: #e3f2fd; border-left: 4px solid #2196F3; padding: 12px; margin: 12px 0; }
        .success { background-color: #e8f5e9; border-left: 4px solid #4CAF50; padding: 12px; margin: 12px 0; }
        table { width: 100%; border-collapse: collapse; margin-top: 15px; }
        th, td { border: 1px solid #ddd; padding: 10px; vertical-align: top; }
        th { background-color: #fafafa; text-align: left; }
        .red { color: #d32f2f; font-weight: bold; }
        .green { color: #2e7d32; font-weight: bold; }
        .sid { font-family: Consolas, monospace; color: #1565c0; }
        .btn { display: inline-block; padding: 10px 16px; background-color: #2196F3; color: #fff; text-decoration: none; border-radius: 4px; margin-top: 14px; }
    </style>
</head>
<body>
<div class="container">
    <h1>클러스터링(세션 페일오버) 테스트</h1>

    <div class="warning">
        <strong>주의:</strong> 이 페이지는 세션/애플리케이션 스코프 동작을 확인하기 위한 테스트입니다.
        운영 환경에서는 부하 및 영향도를 고려해 사용하세요.
    </div>

    <div class="info">
        같은 브라우저로 페이지를 새로고침할 때 세션 카운터가 증가하는지,
        서버 재기동/노드 전환 후에도 세션이 유지되는지(클러스터 환경) 확인할 수 있습니다.
    </div>

    <%
        session = request.getSession(true);
        String ssid = session.getId();

        Integer sessionCount = (Integer) session.getAttribute("simplesession.counter");
        if (sessionCount == null) {
            sessionCount = Integer.valueOf(1);
        } else {
            sessionCount = Integer.valueOf(sessionCount.intValue() + 1);
        }
        session.setAttribute("simplesession.counter", sessionCount);

        Integer appCount = (Integer) application.getAttribute("simplesession.hitcount");
        if (appCount == null) {
            appCount = Integer.valueOf(1);
        } else {
            appCount = Integer.valueOf(appCount.intValue() + 1);
        }
        application.setAttribute("simplesession.hitcount", appCount);

        System.out.println("[FailoverTest] sessionCount=" + sessionCount + ", appCount=" + appCount);
    %>

    <div class="success">
        <strong>현재 세션 ID:</strong> <span class="sid"><%= ssid %></span>
    </div>

    <table>
        <tr>
            <th style="width:50%;">세션 스코프(Session Scope)</th>
            <th style="width:50%;">애플리케이션 스코프(Application Scope)</th>
        </tr>
        <tr>
            <td>
                이 브라우저 세션에서 이 페이지에 접근한 횟수는
                <span class="red"><%= sessionCount %></span>회입니다.
                <br><br>
                이 값은 <code>HttpSession</code>의
                <code>simplesession.counter</code>에 저장됩니다.
                세션이 만료되면 다시 1부터 시작합니다.
            </td>
            <td>
                전체 애플리케이션 기준 누적 접근 횟수는
                <span class="green"><%= appCount %></span>회입니다.
                <br><br>
                이 값은 <code>ServletContext</code>의
                <code>simplesession.hitcount</code>에 저장되며,
                모든 사용자 요청에서 공통으로 증가합니다.
            </td>
        </tr>
    </table>

    <div class="info">
        <strong>점검 방법</strong><br>
        1. 페이지를 여러 번 새로고침하여 세션 카운터 증가 확인<br>
        2. 다른 브라우저/시크릿 창에서 접속하여 세션 카운터 분리 확인<br>
        3. 클러스터 환경에서 노드 변경 후 세션 유지 여부 확인
    </div>

    <a href="index.jsp" class="btn">메인으로 돌아가기</a>
</div>
</body>
</html>
