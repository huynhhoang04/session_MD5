FROM alpine:latest
RUN apk add --no-cache python3
CMD mkdir -p /app/actuator && \
    echo '{"status":"UP"}' > /app/actuator/health && \
    cd /app && python3 -m http.server 8080