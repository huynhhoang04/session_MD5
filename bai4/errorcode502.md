Bản chất lỗi: 502 Bad Gateway xuất hiện khi máy chủ đóng vai trò là Cổng (Gateway - ở đây là Nginx) không nhận được phản hồi hợp lệ từ máy chủ phía sau (Upstream - ở đây là các microservice).

Nguyên nhân gốc rễ: Trong nginx.conf, dev đang cấu hình proxy_pass http://localhost:8081/. Đối với Nginx chạy trực tiếp trên máy chủ vật lý, cấu hình này đúng. Nhưng trong Docker, mỗi container là một cỗ máy độc lập. Chữ localhost lúc này ám chỉ chính bản thân container nginx_proxy. Nginx sẽ tự tìm cổng 8081 trên chính nó, tất nhiên là không có dịch vụ nào chạy ở đó nên nó báo lỗi 502.

Cách khắc phục: Lợi dụng DNS nội bộ của Docker Compose, ta chỉ cần thay localhost bằng tên của service (ví dụ: user_service). Docker sẽ tự động dịch tên này thành địa chỉ IP chuẩn xác của container đó.

Rewrite Path (Trailing Slash): Khi cấu hình proxy_pass http://user_service:8081/; (có dấu gạch chéo ở cuối), Nginx sẽ tự động "cắt bỏ" cụm /users/ trên URL và chỉ đẩy path gốc / vào cho backend.
