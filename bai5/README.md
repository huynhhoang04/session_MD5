# Hướng dẫn Deploy hệ thống StoreX Multi-Environment

Dự án này sử dụng tính năng override của Docker Compose để quản lý cấu hình cho các môi trường khác nhau, tuân thủ nguyên tắc DRY.

## 1. Triển khai môi trường Staging / Local Dev
Mặc định Docker sẽ tự động gộp file `docker-compose.yml` và `docker-compose.override.yml`. 
- **Đặc điểm:** Chỉ chạy 1 replica, mở sẵn port 8080 và 5005 để developer có thể attach debugger.
- **Câu lệnh khởi chạy:**
  ```bash
  docker compose up -d