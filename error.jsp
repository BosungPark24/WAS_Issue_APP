<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page isErrorPage="true" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>에러 페이지</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; background-color: #f5f5f5; }
        .container { max-width: 800px; margin: 0 auto; background: white; padding: 20px; border-radius: 8px; }
        .error { background-color: #ffebee; border-left: 4px solid #f44336; padding: 15px; margin: 20px 0; }
        .btn { display: inline-block; padding: 10px 20px; background-color: #2196F3; color: white; text-decoration: none; border-radius: 4px; margin: 5px; }
    </style>
</head>
<body>
    <div class="container">
        <h1>에러 발생</h1>
        
        <div class="error">
            <h2>에러 정보</h2>
            <% if (exception != null) { %>
                <p><strong>에러 타입:</strong> <%= exception.getClass().getName() %></p>
                <p><strong>에러 메시지:</strong> <%= exception.getMessage() %></p>
            <% } else { %>
                <p>알 수 없는 에러가 발생했습니다.</p>
            <% } %>
        </div>
        
        <a href="index.jsp" class="btn">메인으로 돌아가기</a>
    </div>
</body>
</html>
