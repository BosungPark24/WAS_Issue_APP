<%@ page import="javax.sql.DataSource" %>
<%@ page import="javax.naming.*" %>
<%@ page import="java.util.*" %>
<%!
    /**
     * DataSource를 자동으로 찾는 메서드
     * 일반적인 JNDI 이름들을 순차적으로 시도
     */
    public static DataSource findDataSource(PageContext pageContext) {
        String[] commonJndiNames = {
            // Tomcat
            "java:comp/env/jdbc/DataSource",
            "java:comp/env/jdbc/DefaultDataSource",
            "java:comp/env/jdbc/myDataSource",
            "java:comp/env/jdbc/TestDB",
            
            // WebLogic
            "jdbc/DataSource",
            "jdbc/DefaultDataSource",
            "jdbc/myDataSource",
            "jdbc/TestDB",
            
            // JBoss/WildFly
            "java:/jdbc/DataSource",
            "java:/jdbc/DefaultDataSource",
            "java:/jdbc/ExampleDS",
            "java:jboss/datasources/ExampleDS",
            "java:jboss/datasources/DataSource",
            
            // JEUS
            "jdbc/DataSource",
            "jdbc/DefaultDataSource"
        };
        
        try {
            Context ctx = new InitialContext();
            
            // 먼저 일반적인 JNDI 이름들을 시도
            for (String jndiName : commonJndiNames) {
                try {
                    Object obj = ctx.lookup(jndiName);
                    if (obj instanceof DataSource) {
                        return (DataSource) obj;
                    }
                } catch (NamingException e) {
                    // 다음 시도
                    continue;
                }
            }
            
            // 컨텍스트를 탐색하여 DataSource 찾기
            String[] contexts = {
                "java:comp/env/jdbc",
                "jdbc",
                "java:/jdbc",
                "java:jboss/datasources"
            };
            
            for (String contextPath : contexts) {
                try {
                    Context subCtx = (Context) ctx.lookup(contextPath);
                    NamingEnumeration<NameClassPair> list = subCtx.list("");
                    while (list.hasMoreElements()) {
                        NameClassPair pair = list.nextElement();
                        String fullJndiName = contextPath + "/" + pair.getName();
                        try {
                            Object obj = ctx.lookup(fullJndiName);
                            if (obj instanceof DataSource) {
                                return (DataSource) obj;
                            }
                        } catch (Exception e) {
                            // 무시
                        }
                    }
                } catch (Exception e) {
                    // 해당 컨텍스트가 없으면 무시
                }
            }
        } catch (Exception e) {
            // JNDI 초기화 실패
        }
        
        return null;
    }
    
    /**
     * 찾은 DataSource의 JNDI 이름 반환
     */
    public static String findDataSourceJndiName() {
        String[] commonJndiNames = {
            "java:comp/env/jdbc/DataSource",
            "java:comp/env/jdbc/DefaultDataSource",
            "java:comp/env/jdbc/myDataSource",
            "java:comp/env/jdbc/TestDB",
            "jdbc/DataSource",
            "jdbc/DefaultDataSource",
            "jdbc/myDataSource",
            "jdbc/TestDB",
            "java:/jdbc/DataSource",
            "java:/jdbc/DefaultDataSource",
            "java:/jdbc/ExampleDS",
            "java:jboss/datasources/ExampleDS",
            "java:jboss/datasources/DataSource"
        };
        
        try {
            Context ctx = new InitialContext();
            
            for (String jndiName : commonJndiNames) {
                try {
                    Object obj = ctx.lookup(jndiName);
                    if (obj instanceof DataSource) {
                        return jndiName;
                    }
                } catch (NamingException e) {
                    continue;
                }
            }
            
            String[] contexts = {
                "java:comp/env/jdbc",
                "jdbc",
                "java:/jdbc",
                "java:jboss/datasources"
            };
            
            for (String contextPath : contexts) {
                try {
                    Context subCtx = (Context) ctx.lookup(contextPath);
                    NamingEnumeration<NameClassPair> list = subCtx.list("");
                    while (list.hasMoreElements()) {
                        NameClassPair pair = list.nextElement();
                        String fullJndiName = contextPath + "/" + pair.getName();
                        try {
                            Object obj = ctx.lookup(fullJndiName);
                            if (obj instanceof DataSource) {
                                return fullJndiName;
                            }
                        } catch (Exception e) {
                            // 무시
                        }
                    }
                } catch (Exception e) {
                    // 무시
                }
            }
        } catch (Exception e) {
            // 무시
        }
        
        return null;
    }
%>
