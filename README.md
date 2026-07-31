# 💬 Chat App Backend (Dart + Shelf + Supabase + WebSocket)

Dự án Backend cho Ứng Dụng Chat Real-Time được viết bằng ngôn ngữ **Dart**, sử dụng framework **Shelf**, hệ quản trị cơ sở dữ liệu **Supabase (PostgreSQL)** và **WebSocket** hỗ trợ nhắn tin thời gian thực đa thiết bị.

---

## 🌟 Tính Năng Nổi Bật

- 🔐 **Xác Thực & Phân Quyền (Authentication)**:
  - Đăng ký, đăng nhập tài khoản.
  - Mã hóa mật khẩu an toàn với **Bcrypt**.
  - Xác thực API thông qua **JWT Token** (JSON Web Token).
- 👤 **Quản Lý Người Dùng (User Management)**:
  - Xem và cập nhật profile cá nhân (họ tên, avatar, tiểu sử, địa chỉ).
  - Tìm kiếm người dùng theo từ khóa (username, email, phone, tên).
- 💬 **Quản Lý Phòng Chat & Tin Nhắn (Rooms & Messages)**:
  - Tạo phòng chat 1:1 (Direct Chat) giữa 2 người dùng.
  - Lấy danh sách các phòng chat cá nhân.
  - Gửi tin nhắn văn bản và tải lịch sử tin nhắn có phân trang (`limit`, `offset`).
- ⚡ **Real-Time WebSockets**:
  - Đẩy thông báo tin nhắn mới (`new_message`) tức thì đến người nhận mà không cần reload/polling.
  - Thông báo khi có phòng chat mới được tạo (`room_created`).
  - Quản lý trạng thái kết nối socket đa thiết bị per-user.
- 🏗️ **Kiến Trúc Chuẩn Clean Architecture / Layered Design**:
  - Phân tách rõ ràng: **Routes ➔ Controllers ➔ Services ➔ Repositories ➔ Models**.
  - Tích hợp Middleware tự động: CORS Header, Logger Request, Authentication JWT Middleware.

---

## 🛠️ Công Nghệ Sử Dụng

- **Language**: Dart (SDK >=3.0)
- **Web Framework**: [Shelf](https://pub.dev/packages/shelf) & [Shelf Router](https://pub.dev/packages/shelf_router)
- **Database**: [Supabase Dart SDK](https://pub.dev/packages/supabase) (PostgreSQL Database)
- **Real-time**: [Shelf Web Socket](https://pub.dev/packages/shelf_web_socket) & `web_socket_channel`
- **Security**: `dart_jsonwebtoken`, `bcrypt`
- **Utilities**: `dotenv`

---

## 📁 Cấu Trúc Thư Mục Dự Án

```text
chat_app_backend/
├── bin/
│   └── server.dart             # Entrypoint chính khởi chạy HTTP & WebSocket Server
├── lib/
│   ├── config/                 # Cấu hình môi trường, Database & WebSocket
│   │   ├── database.dart
│   │   ├── env.dart
│   │   └── websocket.dart
│   ├── core/                   # Các thành phần dùng chung (Middleware, Security, Utils)
│   │   ├── exceptions/         # Xử lý ngoại lệ chuẩn (AppException)
│   │   ├── middleware/         # CORS, Auth JWT Middleware, Logger
│   │   ├── security/           # JWT Helper, Bcrypt Helper
│   │   └── utils/              # ResponseUtils chuẩn hóa dữ liệu trả về
│   ├── models/                 # Model dữ liệu (User, Room, Message, Response)
│   ├── repositories/           # Tầng tương tác trực tiếp với Supabase Database
│   ├── services/               # Tầng xử lý Logic nghiệp vụ (Auth, User, Room, Message, WebSocket)
│   ├── controllers/            # Tầng tiếp nhận & phản hồi HTTP Request
│   ├── routes/                 # Khai báo đường dẫn API (AuthRoutes, UserRoutes, RoomRoutes, MessageRoutes)
│   └── app.dart                # Khởi tạo App Pipeline Router & Middlewares
├── .env                        # File chứa biến môi trường (Database Key, JWT Secret)
├── API_DOCS.md                 # Tài liệu chi tiết các API & Request Body
├── pubspec.yaml                # Khai báo thư viện phụ thuộc Dart
└── README.md                   # Hướng dẫn dự án
```

---

## ⚙️ Hướng Dẫn Cài Đặt & Chạy Server

### 1. Yêu Cầu Tiền Đề
- [Dart SDK](https://dart.dev/get-dart) (phiên bản 3.0 trở lên).

### 2. Thiết Lập Biến Môi Trường (`.env`)
Tạo file `.env` tại thư mục gốc của dự án với nội dung mẫu:

```env
PORT=8080
HOST=0.0.0.0
JWT_SECRET=your_super_secret_jwt_key_here
SUPABASE_URL=https://your-supabase-project.supabase.co
SUPABASE_KEY=your_supabase_anon_key_here
```

### 3. Tải Các Thư Viện (Dependencies)
```bash
dart pub get
```

### 4. Khởi Chạy Server
```bash
dart run bin/server.dart
```

Khi server khởi chạy thành công, log terminal sẽ hiển thị:
```text
Initialized Supabase Client for https://...
Server listening on http://0.0.0.0:8080
WebSocket endpoint available at ws://0.0.0.0:8080/ws?token=<jwt_token>
```

---

## 📑 Tài Liệu API & Request Body

Xem chi tiết danh sách API, mẫu Request Body, Query Parameters và Response tại file **[API_DOCS.md](file:///d:/flutter_project/chat_app_backend/API_DOCS.md)**.

### Tóm Tắt Nhanh Các API Chính:

| HTTP Method | Endpoint | Mô tả | Yêu cầu Auth |
| :--- | :--- | :--- | :---: |
| `POST` | `/api/auth/register` | Đăng ký tài khoản mới | ❌ |
| `POST` | `/api/auth/login` | Đăng nhập lấy JWT Token | ❌ |
| `GET` | `/api/users/profile` | Xem thông tin cá nhân | ✅ |
| `PUT` | `/api/users/profile` | Cập nhật thông tin cá nhân | ✅ |
| `GET` | `/api/users?keyword=` | Tìm kiếm người dùng | ✅ |
| `POST` | `/api/rooms/direct` | Tạo phòng chat 1:1 | ✅ |
| `GET` | `/api/rooms` | Danh sách phòng chat của tôi | ✅ |
| `POST` | `/api/messages` | Gửi tin nhắn mới | ✅ |
| `GET` | `/api/messages/room/<id>`| Lịch sử tin nhắn phòng chat | ✅ |
| `WS` | `/ws?token=<token>` | Kết nối WebSocket Real-time | ✅ |

---

## 🧪 Hướng Dẫn Test API

- **Sử dụng Postman / Thunder Client**:
  - Gửi request đến `http://localhost:8080/api/...`
  - Đính kèm Header `Authorization: Bearer <TOKEN>` cho các API có yêu cầu xác thực.
- **Sử dụng WebSocket Test**:
  - Kết nối đến `ws://localhost:8080/ws?token=<TOKEN_CUA_CLIENT>` để trải nghiệm nhận tin nhắn tự động thời gian thực.
