FROM maven:3.9.9-eclipse-temurin-17 AS build
WORKDIR /workspace

COPY pom.xml .
COPY src ./src
COPY WEB-INF ./WEB-INF
COPY *.jsp ./

RUN mvn -DskipTests package

FROM eclipse-temurin:17-jre
WORKDIR /app
COPY --from=build /workspace/target/bosung-app.war /app/bosung-app.war

EXPOSE 8080
ENTRYPOINT ["java", "-jar", "/app/bosung-app.war"]
