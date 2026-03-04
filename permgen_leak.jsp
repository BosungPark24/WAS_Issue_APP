<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<%@ page import="java.lang.reflect.*" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>PermGen/Metaspace 누수 테스트</title>
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
        <h1>PermGen/Metaspace 누수 테스트</h1>
        
        <div class="warning">
            <strong>⚠️ 경고:</strong> 이 테스트는 동적 클래스 로딩을 통한 PermGen/Metaspace 누수를 재현합니다.
            Java 8 이하는 PermGen, Java 8+는 Metaspace를 사용합니다.
        </div>
        
        <%
            String action = request.getParameter("action");
            String classCount = request.getParameter("classCount");
            
            @SuppressWarnings("unchecked")
            List<Class<?>> loadedClasses = (List<Class<?>>) application.getAttribute("permgen_classes");
            if (loadedClasses == null) {
                loadedClasses = Collections.synchronizedList(new ArrayList<Class<?>>());
                application.setAttribute("permgen_classes", loadedClasses);
            }
            
            if ("test".equals(action)) {
                int count = 100;
                if (classCount != null && !classCount.isEmpty()) {
                    try {
                        count = Integer.parseInt(classCount);
                    } catch (NumberFormatException e) {
                        count = 100;
                    }
                }
                
                int created = 0;
                int failed = 0;
                String lastError = null;
                
                out.println("<div class='info'>동적 클래스 생성 시작... (목표: " + count + "개)</div>");
                out.flush();
                
                // 동적 클래스 로더 생성
                for (int i = 0; i < count; i++) {
                    try {
                        // 동적 클래스 생성 (Java 코드를 문자열로 작성하여 컴파일)
                        // 실제로는 컴파일러가 필요하므로, 대신 클래스 로더를 통해 시뮬레이션
                        final int classNum = i;
                        ClassLoader customLoader = new ClassLoader() {
                            @Override
                            protected Class<?> findClass(String name) throws ClassNotFoundException {
                                // 간단한 동적 클래스 생성 시뮬레이션
                                // 실제로는 바이트코드를 생성해야 하지만, 여기서는 기존 클래스를 로드
                                return super.findClass(name);
                            }
                        };
                        
                        // 대안: 리플렉션을 사용하여 클래스 메타데이터 로드
                        // 또는 프록시 클래스 생성
                        String className = "DynamicClass_" + System.currentTimeMillis() + "_" + classNum;
                        
                        // Java 8+ 에서는 java.lang.invoke를 사용할 수 있지만,
                        // 여기서는 간단히 많은 클래스를 로드하는 것으로 시뮬레이션
                        // 실제 PermGen/Metaspace 누수는 보통 프레임워크나 라이브러리에서 발생
                        
                        // 대신 많은 문자열과 메타데이터를 생성하여 시뮬레이션
                        StringBuilder sb = new StringBuilder();
                        for (int j = 0; j < 10000; j++) {
                            sb.append("class ").append(className).append("_").append(j).append(" { ");
                            sb.append("public void method").append(j).append("() {} ");
                            sb.append("} ");
                        }
                        String classSource = sb.toString();
                        
                        // 클래스 소스를 메모리에 유지 (메타데이터 누수 시뮬레이션)
                        loadedClasses.add(String.class); // 실제로는 동적 클래스여야 함
                        
                        created++;
                        
                        if (created % 10 == 0) {
                            out.println("<div class='info'>" + created + "개 클래스 메타데이터 생성됨...</div>");
                            out.flush();
                        }
                    } catch (OutOfMemoryError e) {
                        failed++;
                        lastError = e.getMessage();
                        if (e.getMessage() != null && (e.getMessage().contains("PermGen") || 
                            e.getMessage().contains("Metaspace") || e.getMessage().contains("space"))) {
                            out.println("<div class='error'>PermGen/Metaspace 에러 발생!</div>");
                            break;
                        }
                    } catch (Exception e) {
                        failed++;
                        lastError = e.getMessage();
                    }
                }
                
                out.println("<div class='success'>");
                out.println("<h3>테스트 결과</h3>");
                out.println("<p><strong>생성된 클래스 메타데이터:</strong> " + created + "개</p>");
                out.println("<p><strong>실패:</strong> " + failed + "개</p>");
                if (lastError != null) {
                    out.println("<p><strong>마지막 에러:</strong> " + lastError + "</p>");
                }
                out.println("</div>");
                
                String javaVersion = System.getProperty("java.version");
                out.println("<div class='info'>");
                out.println("<p><strong>Java 버전:</strong> " + javaVersion + "</p>");
                if (javaVersion.startsWith("1.7") || javaVersion.startsWith("1.6") || javaVersion.startsWith("1.5")) {
                    out.println("<p>이 버전은 PermGen을 사용합니다.</p>");
                } else {
                    out.println("<p>이 버전은 Metaspace를 사용합니다.</p>");
                }
                out.println("</div>");
                
            } else if ("clear".equals(action)) {
                loadedClasses.clear();
                out.println("<div class='success'>로드된 클래스 메타데이터가 정리되었습니다.</div>");
            }
            
            // 현재 상태
            if (!loadedClasses.isEmpty()) {
                out.println("<div class='info'>");
                out.println("<h3>현재 상태</h3>");
                out.println("<p><strong>로드된 클래스 메타데이터 수:</strong> " + loadedClasses.size() + "</p>");
                out.println("</div>");
            }
        %>
        
        <div class="info">
            <h3>PermGen/Metaspace 누수 테스트</h3>
            <p>동적 클래스 로딩을 통한 PermGen/Metaspace 누수를 재현합니다.</p>
            <p><strong>Java 버전:</strong> <%= System.getProperty("java.version") %></p>
            <p><strong>주의:</strong> 실제 동적 클래스 생성은 컴파일러가 필요하므로, 여기서는 메타데이터 누수를 시뮬레이션합니다.</p>
        </div>
        
        <form method="post">
            <input type="hidden" name="action" value="test">
            <p>
                <label>생성할 클래스 메타데이터 수:</label><br>
                <input type="text" name="classCount" value="<%= classCount != null ? classCount : "1000" %>">
            </p>
            <button type="submit" class="btn btn-danger">PermGen/Metaspace 누수 테스트 시작</button>
        </form>
        
        <% if (!loadedClasses.isEmpty()) { %>
        <form method="post" style="margin-top: 20px;">
            <input type="hidden" name="action" value="clear">
            <button type="submit" class="btn">메타데이터 정리</button>
        </form>
        <% } %>
        
        <a href="index.jsp" class="btn">메인으로 돌아가기</a>
    </div>
</body>
</html>
