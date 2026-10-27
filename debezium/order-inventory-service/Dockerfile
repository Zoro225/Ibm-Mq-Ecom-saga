FROM eclipse-temurin:17-jre

WORKDIR /app

RUN useradd --system --uid 10001 appuser

COPY target/order-inventory-service-1.0.0.jar app.jar

USER 10001

EXPOSE 8081

ENTRYPOINT ["java", "-jar", "/app/app.jar"]
