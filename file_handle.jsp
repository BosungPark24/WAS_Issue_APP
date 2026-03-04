<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.io.*" %>
<%@ page import="java.util.*" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>파일 핸들러 누수 테스트</title>
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
        <h1>파일 핸들러 누수 테스트</h1>
        
        <div class="warning">
            <strong>⚠️ 경고:</strong> 이 테스트는 파일 핸들을 열고 닫지 않아 파일 핸들러 누수를 재현합니다.
            "Too many open files" 에러가 발생할 수 있습니다.
        </div>
        
        <%
            String action = request.getParameter("action");
            String fileCount = request.getParameter("fileCount");
            String closeFiles = request.getParameter("closeFiles");
            
            if ("test".equals(action)) {
                int count = 100;
                if (fileCount != null && !fileCount.isEmpty()) {
                    try {
                        count = Integer.parseInt(fileCount);
                    } catch (NumberFormatException e) {
                        count = 100;
                    }
                }
                
                @SuppressWarnings("unchecked")
                List<FileInputStream> openFiles = (List<FileInputStream>) application.getAttribute("test_file_handles");
                if (openFiles == null) {
                    openFiles = Collections.synchronizedList(new ArrayList<FileInputStream>());
                    application.setAttribute("test_file_handles", openFiles);
                }

                @SuppressWarnings("unchecked")
                List<File> createdFiles = (List<File>) application.getAttribute("test_temp_files");
                if (createdFiles == null) {
                    createdFiles = Collections.synchronizedList(new ArrayList<File>());
                    application.setAttribute("test_temp_files", createdFiles);
                }

                @SuppressWarnings("unchecked")
                List<File> createdDirs = (List<File>) application.getAttribute("test_temp_dirs");
                if (createdDirs == null) {
                    createdDirs = Collections.synchronizedList(new ArrayList<File>());
                    application.setAttribute("test_temp_dirs", createdDirs);
                }
                
                // 임시 디렉토리 생성
                File tempDir = new File(System.getProperty("java.io.tmpdir"), "was_test_" + System.currentTimeMillis());
                tempDir.mkdirs();
                createdDirs.add(tempDir);
                
                int created = 0;
                int failed = 0;
                String lastError = null;
                
                out.println("<div class='info'>파일 핸들 생성 시작... (목표: " + count + "개)</div>");
                out.flush();
                
                for (int i = 0; i < count; i++) {
                    try {
                        File tempFile = new File(tempDir, "test_file_" + i + ".tmp");
                        tempFile.createNewFile();
                        createdFiles.add(tempFile);
                        
                        FileInputStream fis = new FileInputStream(tempFile);
                        openFiles.add(fis);
                        created++;
                        
                        // 파일 핸들을 닫지 않음 (누수 시뮬레이션)
                        
                        if (created % 10 == 0) {
                            out.println("<div class='info'>" + created + "개 파일 핸들 생성됨...</div>");
                            out.flush();
                        }
                    } catch (IOException e) {
                        failed++;
                        lastError = e.getMessage();
                        if (e.getMessage() != null && (e.getMessage().contains("too many") || 
                            e.getMessage().contains("Too many open files"))) {
                            break;
                        }
                    }
                }
                
                out.println("<div class='success'>");
                out.println("<h3>테스트 결과</h3>");
                out.println("<p><strong>생성된 파일 핸들:</strong> " + created + "개</p>");
                out.println("<p><strong>실패한 파일 핸들:</strong> " + failed + "개</p>");
                if (lastError != null) {
                    out.println("<p><strong>마지막 에러:</strong> " + lastError + "</p>");
                }
                out.println("<p><strong>임시 디렉토리:</strong> " + tempDir.getAbsolutePath() + "</p>");
                out.println("</div>");
                
                if (lastError != null && lastError.contains("too many")) {
                    out.println("<div class='error'>");
                    out.println("<h3>파일 핸들러 한계 도달!</h3>");
                    out.println("<p>시스템의 최대 파일 핸들 수에 도달했습니다.</p>");
                    out.println("</div>");
                }
                
            } else if ("close".equals(closeFiles)) {
                @SuppressWarnings("unchecked")
                List<FileInputStream> openFiles = (List<FileInputStream>) application.getAttribute("test_file_handles");
                @SuppressWarnings("unchecked")
                List<File> createdFiles = (List<File>) application.getAttribute("test_temp_files");
                @SuppressWarnings("unchecked")
                List<File> createdDirs = (List<File>) application.getAttribute("test_temp_dirs");
                int closed = 0;
                if (openFiles != null) {
                    synchronized (openFiles) {
                        for (FileInputStream fis : openFiles) {
                            try {
                                if (fis != null) {
                                    fis.close();
                                    closed++;
                                }
                            } catch (IOException e) {
                                // 무시
                            }
                        }
                        openFiles.clear();
                    }
                    application.removeAttribute("test_file_handles");
                }

                int deletedFiles = 0;
                if (createdFiles != null) {
                    synchronized (createdFiles) {
                        for (File f : createdFiles) {
                            if (f != null && f.exists() && f.delete()) {
                                deletedFiles++;
                            }
                        }
                        createdFiles.clear();
                    }
                    application.removeAttribute("test_temp_files");
                }

                int deletedDirs = 0;
                if (createdDirs != null) {
                    synchronized (createdDirs) {
                        for (File d : createdDirs) {
                            if (d != null && d.exists() && d.delete()) {
                                deletedDirs++;
                            }
                        }
                        createdDirs.clear();
                    }
                    application.removeAttribute("test_temp_dirs");
                }

                out.println("<div class='success'>" + closed + "개의 파일 핸들을 닫고, 임시 파일 " + deletedFiles + "개/디렉토리 " + deletedDirs + "개를 정리했습니다.</div>");
            }
            
            // 현재 파일 핸들 상태
            @SuppressWarnings("unchecked")
            List<FileInputStream> openFiles = (List<FileInputStream>) application.getAttribute("test_file_handles");
            if (openFiles != null && !openFiles.isEmpty()) {
                out.println("<div class='info'>");
                out.println("<h3>현재 파일 핸들 상태</h3>");
                out.println("<p><strong>열린 파일 핸들 수:</strong> " + openFiles.size() + "</p>");
                out.println("<p><strong>주의:</strong> 이 파일 핸들들은 닫히지 않아 누수 상태입니다.</p>");
                out.println("</div>");
            }
        %>
        
        <div class="info">
            <h3>파일 핸들러 누수 테스트</h3>
            <p>파일 핸들을 열고 닫지 않아 파일 핸들러 누수를 재현합니다.</p>
            <p><strong>시스템 임시 디렉토리:</strong> <%= System.getProperty("java.io.tmpdir") %></p>
        </div>
        
        <form method="post">
            <input type="hidden" name="action" value="test">
            <p>
                <label>생성할 파일 핸들 수:</label><br>
                <input type="text" name="fileCount" value="<%= fileCount != null ? fileCount : "500" %>">
            </p>
            <button type="submit" class="btn btn-danger">파일 핸들 생성 시작</button>
        </form>
        
        <% if (application.getAttribute("test_file_handles") != null) { %>
        <form method="post" style="margin-top: 20px;">
            <input type="hidden" name="closeFiles" value="close">
            <button type="submit" class="btn">모든 파일 핸들 닫기</button>
        </form>
        <% } %>
        
        <a href="index.jsp" class="btn">메인으로 돌아가기</a>
    </div>
</body>
</html>
