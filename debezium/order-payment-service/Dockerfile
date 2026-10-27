FROM eclipse-temurin:17-jre

WORKDIR /app

RUN useradd --system --uid 10001 appuser

COPY target/order-payment-service-1.0.0.jar app.jar

USER 10001

EXPOSE 8082

ENTRYPOINT ["java", "-jar", "/app/app.jar"]
