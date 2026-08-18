# Giải thích cơ chế Healthcheck và Depends_on:

1. Lỗi ban đầu: Mặc định depends_on của Docker Compose chỉ đợi tiến trình container được khởi tạo xong là lập tức chạy Backend. Nó không biết rằng ứng dụng PostgreSQL hay Redis bên trong cần mất vài giây để nạp dữ liệu và mở cổng kết nối, dẫn đến Backend bị crash do kết nối hụt.

2. Cơ chế Healthcheck:

    - Với PostgreSQL: Sử dụng lệnh pg_isready để ping liên tục vào database. Chỉ khi nào Postgres trả về trạng thái sẵn sàng nhận kết nối thì mới tính là healthy.

    - Với Redis: Sử dụng lệnh redis-cli ping. Khi Redis trả lời là PONG thì tính là healthy.

3. Condition service_healthy: Khi kết hợp depends_on với điều kiện service_healthy, container backend sẽ bị "giam" lại, không được phép khởi động cho đến khi Docker xác nhận cả 2 bài test Healthcheck của DB và Redis đều đã Pass (thành công). Nhờ vậy, Backend luôn khởi động an toàn.

4. Volumes pg_data: Được khai báo để mount vào đường dẫn /var/lib/postgresql/data trong container. Nhờ cơ chế Named Volumes này của Docker, dữ liệu vật lý được lưu trữ độc lập trên máy Host. Khi chạy docker-compose down, container bị xóa nhưng Volume vẫn còn. Ở lần up tiếp theo, dữ liệu cũ sẽ tự động được gắn lại.