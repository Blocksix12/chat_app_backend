# 🚀 API Documentation & Request Body Guide

Tài liệu tổng hợp đầy đủ các Endpoint API, Header, Request Body (dữ liệu gửi lên) và Response mẫu cho hệ thống **Chat App Backend** (Dart Shelf + Supabase + WebSocket).

---

## 📌 1. Thông Tin Chung

- **Base URL**: `http://localhost:8080` (hoặc IP server của bạn)
- **Content-Type**: `application/json` (cho các request `POST` / `PUT`)
- **Xác thực (Authentication)**: Đa số các API yêu cầu JWT Token trong Header:
  ```http
  Authorization: Bearer <YOUR_JWT_TOKEN>
  ```

---

## 🔑 2. Phân Hệ Auth (`/api/auth`)

### 2.1. Đăng ký tài khoản (`POST /api/auth/register`)
Đăng ký người dùng mới vào hệ thống.

- **URL**: `http://localhost:8080/api/auth/register`
- **Auth**: Không yêu cầu
- **Request Body (JSON)**:
  ```json
  {
    "username": "hoangkhoa",
    "email": "khoa@example.com",
    "phone": "0987654321",
    "password": "password123"
  }
  ```
  *Bắt buộc: `username`, `email`, `phone`, `password`.*

- **Response (201 Created)**:
  ```json
  {
    "success": true,
    "message": "Registered successfully",
    "data": {
      "user": {
        "id": "a1b2c3d4-...",
        "email": "khoa@example.com",
        "username": "hoangkhoa",
        "phone": "0987654321"
      },
      "token": "eyJhbGciOi..."
    }
  }
  ```

---

### 2.2. Đăng nhập (`POST /api/auth/login`)
Đăng nhập lấy JWT Token.

- **URL**: `http://localhost:8080/api/auth/login`
- **Auth**: Không yêu cầu
- **Request Body (JSON)**:
  ```json
  {
    "email": "khoa@example.com",
    "password": "password123"
  }
  ```
  *Bắt buộc: `email`, `password`.*

- **Response (200 OK)**:
  ```json
  {
    "success": true,
    "message": "Logged in successfully",
    "data": {
      "token": "eyJhbGciOi...",
      "user": {
        "id": "a1b2c3d4-...",
        "email": "khoa@example.com"
      }
    }
  }
  ```

---

### 2.3. Tạo Token theo User ID (`POST /api/auth/token`)
Tạo nhanh token cho 1 User ID (Dùng khi debug/test).

- **URL**: `http://localhost:8080/api/auth/token`
- **Auth**: Không yêu cầu
- **Request Body (JSON)**:
  ```json
  {
    "user_id": "a1b2c3d4-..."
  }
  ```

---

## 👤 3. Phân Hệ Người Dùng (`/api/users`)

### 3.1. Xem Thông Tin Profile Cá Nhân (`GET /api/users/profile`)
Lấy thông tin cá nhân của người dùng đang đăng nhập.

- **URL**: `http://localhost:8080/api/users/profile`
- **Auth**: `Authorization: Bearer <TOKEN>`
- **Response (200 OK)**:
  ```json
  {
    "success": true,
    "message": "Get profile successfully",
    "data": {
      "id": "a1b2c3d4-...",
      "username": "hoangkhoa",
      "email": "khoa@example.com",
      "full_name": "Nguyễn Hoàng Khoa",
      "avatar_url": "https://example.com/avatar.jpg",
      "bio": "Xin chào!",
      "address": "TP.HCM"
    }
  }
  ```

---

### 3.2. Cập Nhật Profile (`PUT /api/users/profile`)
Cập nhật thông tin hồ sơ người dùng.

- **URL**: `http://localhost:8080/api/users/profile`
- **Auth**: `Authorization: Bearer <TOKEN>`
- **Request Body (JSON)**:
  ```json
  {
    "full_name": "Nguyễn Hoàng Khoa (Updated)",
    "avatar_url": "https://example.com/new_avatar.jpg",
    "bio": "Flutter Developer",
    "address": "Hà Nội"
  }
  ```
  *(Các trường trên đều không bắt buộc, chỉ gửi các trường cần cập nhật).*

---

### 3.3. Tìm Kiếm Người Dùng (`GET /api/users`)
Tìm kiếm người dùng theo từ khóa (username / email / phone / full_name).

- **URL**: `http://localhost:8080/api/users?keyword=khoa`
- **Auth**: `Authorization: Bearer <TOKEN>`
- **Query Params**:
  - `keyword` (String): Từ khóa cần tìm.
- **Response (200 OK)**:
  ```json
  {
    "success": true,
    "message": "Search users successfully",
    "data": [
      {
        "id": "a1b2c3d4-...",
        "username": "hoangkhoa",
        "email": "khoa@example.com",
        "full_name": "Nguyễn Hoàng Khoa"
      }
    ]
  }
  ```

---

## 🚪 4. Phân Hệ Phòng Chat (`/api/rooms`)

### 4.1. Tạo Phòng Chat 1:1 (`POST /api/rooms/direct`)
Tạo phòng chat trực tiếp giữa 2 người dùng. Nếu phòng chat đã tồn tại, hệ thống trả về thông tin phòng chat cũ.

- **URL**: `http://localhost:8080/api/rooms/direct`
- **Auth**: `Authorization: Bearer <TOKEN>`
- **Request Body (JSON)**:
  ```json
  {
    "target_user_id": "b9876543-..."
  }
  ```
  *Bắt buộc: `target_user_id` (UUID người dùng muốn chat cùng).*

- **Response (201 Created)**:
  ```json
  {
    "success": true,
    "message": "Chat room created successfully",
    "data": {
      "id": "room-uuid-1234",
      "type": "direct",
      "created_at": "2026-07-31T...",
      "members": [...]
    }
  }
  ```

---

### 4.2. Lấy Danh Sách Phòng Chat Của Tôi (`GET /api/rooms`)
Lấy toàn bộ các phòng chat mà người dùng tham gia.

- **URL**: `http://localhost:8080/api/rooms`
- **Auth**: `Authorization: Bearer <TOKEN>`
- **Response (200 OK)**:
  ```json
  {
    "success": true,
    "message": "Fetched rooms successfully",
    "data": [
      {
        "id": "room-uuid-1234",
        "type": "direct",
        "last_message": "Chào bạn!",
        "updated_at": "2026-07-31T..."
      }
    ]
  }
  ```

---

### 4.3. Xem Chi Tiết 1 Phòng Chat (`GET /api/rooms/<id>`)
- **URL**: `http://localhost:8080/api/rooms/room-uuid-1234`
- **Auth**: `Authorization: Bearer <TOKEN>`

---

## 💬 5. Phân Hệ Tin Nhắn (`/api/messages`)

### 5.1. Gửi Tin Nhắn (`POST /api/messages`)
Gửi tin nhắn văn bản vào một phòng chat.

- **URL**: `http://localhost:8080/api/messages`
- **Auth**: `Authorization: Bearer <TOKEN>`
- **Request Body (JSON)**:
  ```json
  {
    "room_id": "room-uuid-1234",
    "content": "Chào bạn, đây là tin nhắn test!"
  }
  ```
  *Bắt buộc: `room_id`, `content`.*

- **Response (201 Created)**:
  ```json
  {
    "success": true,
    "message": "Message sent successfully",
    "data": {
      "id": "msg-uuid-5678",
      "room_id": "room-uuid-1234",
      "sender_id": "a1b2c3d4-...",
      "content": "Chào bạn, đây là tin nhắn test!",
      "created_at": "2026-07-31T18:00:00.000Z"
    }
  }
  ```

---

### 5.2. Lấy Danh Sách Tin Nhắn Trong Phòng (`GET /api/messages/room/<roomId>`)
Lấy tin nhắn cũ trong phòng chat (hỗ trợ phân trang limit / offset).

- **URL**: `http://localhost:8080/api/messages/room/room-uuid-1234?limit=50&offset=0`
- **Auth**: `Authorization: Bearer <TOKEN>`
- **Query Params**:
  - `limit` (int, tùy chọn, mặc định `50`)
  - `offset` (int, tùy chọn, mặc định `0`)

- **Response (200 OK)**:
  ```json
  {
    "success": true,
    "message": "Fetched room messages successfully",
    "data": [
      {
        "id": "msg-uuid-5678",
        "room_id": "room-uuid-1234",
        "sender_id": "a1b2c3d4-...",
        "content": "Chào bạn, đây là tin nhắn test!",
        "created_at": "2026-07-31T18:00:00.000Z"
      }
    ]
  }
  ```

---

## ⚡ 6. WebSocket Real-Time (`/ws`)

Hệ thống hỗ trợ kết nối WebSocket đẩy thông báo tin nhắn mới và phòng mới cho Client theo thời gian thực.

- **URL kết nối**: `ws://localhost:8080/ws?token=<YOUR_JWT_TOKEN>`

### 6.1. Event nhận được khi kết nối thành công:
```json
{
  "event": "connected",
  "data": {
    "userId": "a1b2c3d4-..."
  }
}
```

### 6.2. Event khi có Tin Nhắn Mới (`new_message`):
Server tự động đẩy về cho các thành viên trong phòng chat khi có người gửi tin nhắn:
```json
{
  "event": "new_message",
  "data": {
    "id": "msg-uuid-5678",
    "room_id": "room-uuid-1234",
    "sender_id": "a1b2c3d4-...",
    "content": "Chào bạn, đây là tin nhắn test!",
    "created_at": "2026-07-31T18:00:00.000Z"
  }
}
```

### 6.3. Event khi Tạo Phòng Chat Mới (`room_created`):
Server tự động đẩy thông tin phòng chat mới về cho `target_user`:
```json
{
  "event": "room_created",
  "data": {
    "id": "room-uuid-1234",
    "type": "direct"
  }
}
```

---

## ⚠️ 7. Định Dạng Lỗi Chung (Error Response Format)

Khi xảy ra lỗi (400, 401, 403, 404, 500...), Server luôn trả về định dạng chuẩn:
```json
{
  "success": false,
  "message": "Chi tiết câu thông báo lỗi"
}
```
