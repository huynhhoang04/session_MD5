#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

COMMAND=$1

if [ "$COMMAND" == "start" ]; then
    echo "Khởi động hệ thống Quickbite..."
    docker compose up -d --build

    echo "Đang kiểm tra sức khỏe Database (timeout 10s)..."
    TIMEOUT=10
    ELAPSED=0
    DB_READY=false

    while [ $ELAPSED -lt $TIMEOUT ]; do
        if docker compose exec -T postgres pg_isready -U postgres > /dev/null 2>&1; then
            DB_READY=true
            echo "Database đã sẵn sàng!"
            break
        fi
        sleep 2
        let ELAPSED=ELAPSED+2
    done

    if [ "$DB_READY" == false ]; then
        echo -e "${RED}[LỖI] Database không sẵn sàng sau ${TIMEOUT}s!${NC}"
        echo "Log Backend (20 dòng cuối):"
        docker compose logs --tail=20 backend
        echo "Hệ thống đang tự động dọn dẹp (Rollback)..."
        docker compose down
        exit 1
    fi

    echo "Đang kiểm tra API Backend..."
    API_READY=false
    API_TIMEOUT=15
    API_ELAPSED=0

    while [ $API_ELAPSED -lt $API_TIMEOUT ]; do
        HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8080/actuator/health)
        if [ "$HTTP_STATUS" == "200" ]; then
            API_READY=true
            break
        fi
        sleep 2
        let API_ELAPSED=API_ELAPSED+2
    done

    if [ "$API_READY" == false ]; then
        echo -e "${RED}[LỖI] API Backend không phản hồi hợp lệ (HTTP $HTTP_STATUS)!${NC}"
        echo "Log Backend (20 dòng cuối):"
        docker compose logs --tail=20 backend
        echo "Hệ thống đang tự động dọn dẹp (Rollback)..."
        docker compose down
        exit 1
    fi

    echo -e "${GREEN}HỆ THỐNG QUICKBITE HOẠT ĐỘNG ỔN ĐỊNH!${NC}"
    exit 0

elif [ "$COMMAND" == "stop" ]; then
    echo "Đang tạm dừng hệ thống Quickbite..."
    docker compose stop
    echo "Đã dừng hệ thống."

elif [ "$COMMAND" == "clean" ]; then
    echo "Đang dọn dẹp toàn bộ tài nguyên, mạng và volumes..."
    docker compose down -v
    echo "Đã dọn dẹp sạch sẽ."

else
    echo "Lỗi: Sai cú pháp!"
    echo "Sử dụng: ./compose-control.sh [start | stop | clean]"
    exit 1
fi