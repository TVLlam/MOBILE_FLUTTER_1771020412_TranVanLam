# 🎾 Pickleball Club Management System

Hệ thống quản lý CLB Pickleball - Vợt Thủ Phố Núi (PCM)

## 📋 Mô tả dự án

Ứng dụng quản lý toàn diện cho câu lạc bộ Pickleball, bao gồm:
- **Backend API**: ASP.NET Core 8.0 với SQL Server
- **Frontend**: Flutter Web Application
- **Realtime**: SignalR cho thông báo tức thời

## ✨ Tính năng chính

### 🔐 Xác thực & Phân quyền
- Đăng ký/Đăng nhập với JWT Authentication
- 2 vai trò: **Member** (Hội viên) và **Admin** (Quản trị viên)
- Bảo mật với Flutter Secure Storage

### 👥 Quản lý hội viên
- Profile cá nhân với avatar
- Thông tin thành viên: loại thẻ, ngày hết hạn
- Quản lý số dư ví điện tử

### 🏟️ Đặt sân
- Xem danh sách sân và lịch trống
- Đặt sân theo giờ với Calendar UI
- Thanh toán qua ví điện tử
- Tự động hủy booking Pending sau 5 phút

### 🏆 Giải đấu
- Danh sách giải đấu với thông tin chi tiết
- Đăng ký tham gia giải (thanh toán qua ví)
- Hủy đăng ký với chính sách hoàn 50%
- Re-registration sau khi hủy

### 💰 Ví điện tử & Giao dịch
- Nạp tiền qua **VietQR** (QR Code tự động)
- Xem lịch sử giao dịch
- Thông tin chuyển khoản:
  - Ngân hàng: Napas 24/7
  - STK: 100714082005
  - Chủ TK: TRAN VAN LAM

### 📰 Tin tức & Thông báo
- Xem tin tức CLB
- Thông báo realtime qua SignalR
- Push notification với Flutter Local Notifications

### 👨‍💼 Chức năng Admin
- Dashboard với thống kê tổng quan
- Quản lý yêu cầu nạp tiền
- Duyệt booking & giao dịch
- Quản lý giải đấu và tin tức

## 🛠️ Công nghệ sử dụng

### Backend
- **Framework**: ASP.NET Core 8.0
- **Database**: SQL Server (LocalDB)
- **ORM**: Entity Framework Core 9.0
- **Authentication**: JWT Bearer
- **Realtime**: SignalR
- **API Documentation**: Swagger/OpenAPI

### Frontend
- **Framework**: Flutter 3.38.3
- **State Management**: Riverpod 2.6
- **Navigation**: GoRouter 13.2
- **HTTP Client**: Dio 5.9
- **Storage**: Flutter Secure Storage, Shared Preferences
- **UI Components**: Material Design 3
- **QR Code**: qr_flutter 4.1

## 📦 Cấu trúc thư mục

```
BT_TUAN8/
├── PickleballAPI/              # Backend ASP.NET Core
│   ├── Controllers/            # API Controllers
│   ├── Models/                 # Entity Models
│   ├── DTOs/                   # Data Transfer Objects
│   ├── Data/                   # DbContext & Seeder
│   ├── Services/               # Business Logic
│   └── Migrations/             # Database Migrations
│
└── pickleball_app/             # Frontend Flutter
    ├── lib/
    │   ├── main.dart           # Entry point
    │   ├── config/             # App configuration
    │   ├── core/               # Theme, utils, constants
    │   ├── data/               # Models, services, repositories
    │   ├── features/           # Feature modules
    │   │   ├── auth/           # Authentication
    │   │   ├── booking/        # Đặt sân
    │   │   ├── tournament/     # Giải đấu
    │   │   ├── wallet/         # Ví điện tử
    │   │   ├── news/           # Tin tức
    │   │   └── admin/          # Admin dashboard
    │   ├── providers/          # Riverpod providers
    │   ├── router/             # GoRouter configuration
    │   └── shared/             # Shared widgets
    └── assets/                 # Images, icons

```

## 🚀 Hướng dẫn chạy dự án

### Yêu cầu hệ thống

- **Flutter SDK**: 3.38.3 trở lên
- **.NET SDK**: 8.0 trở lên
- **SQL Server**: SQL Server LocalDB hoặc SQL Server Express
- **Chrome**: Để chạy Flutter Web

### 1️⃣ Cài đặt Backend

```powershell
# Di chuyển vào thư mục backend
cd PickleballAPI

# Restore packages
dotnet restore

# Tạo database và chạy migrations
dotnet ef database update

# Chạy backend
dotnet run
```

Backend sẽ chạy tại: **http://localhost:5159**

Swagger UI: **http://localhost:5159/swagger**

### 2️⃣ Cài đặt Frontend

```powershell
# Di chuyển vào thư mục frontend
cd pickleball_app

# Cài đặt dependencies
flutter pub get

# Chạy trên Chrome
flutter run -d chrome --web-port=8080
```

Frontend sẽ chạy tại: **http://localhost:8080**

### 3️⃣ Tài khoản demo

#### 👤 Member (Hội viên)
- **Email**: member@pickleball.com
- **Password**: Member@123
- **Số dư ví**: 5,000,000 VNĐ

#### 👨‍💼 Admin (Quản trị viên)
- **Email**: admin@pickleball.com
- **Password**: Admin@123

## 📱 Hướng dẫn sử dụng

### Đặt sân
1. Đăng nhập với tài khoản Member
2. Vào menu **Đặt sân**
3. Chọn sân và xem lịch trống
4. Chọn ngày, giờ bắt đầu và kết thúc
5. Xác nhận thanh toán → Tiền tự động trừ từ ví

### Đăng ký giải đấu
1. Vào menu **Giải đấu**
2. Chọn giải muốn tham gia
3. Nhấn **"ĐĂNG KÝ NGAY"**
4. Xác nhận thanh toán → Đăng ký thành công
5. Có thể hủy đăng ký (hoàn 50% phí)

### Nạp tiền vào ví
1. Vào menu **Ví**
2. Nhấn **"Nạp tiền"**
3. Nhập số tiền muốn nạp
4. **Quét mã QR VietQR** bằng app ngân hàng
   - Hoặc chuyển khoản thủ công theo thông tin hiển thị
5. Chụp/tải ảnh xác nhận chuyển khoản
6. Gửi yêu cầu → Chờ Admin duyệt

### Admin duyệt giao dịch
1. Đăng nhập với tài khoản Admin
2. Vào **Dashboard**
3. Xem danh sách **Yêu cầu nạp tiền**
4. Nhấn **"Duyệt"** để xác nhận
5. Tiền tự động cộng vào ví member

## 🔧 Cấu hình

### Backend Configuration (appsettings.json)

```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Server=(localdb)\\mssqllocaldb;Database=PickleballDB;Trusted_Connection=true;TrustServerCertificate=true"
  },
  "Jwt": {
    "Key": "YourSuperSecretKeyHere123456789012345678901234567890",
    "Issuer": "PickleballAPI",
    "Audience": "PickleballApp"
  }
}
```

### Frontend Configuration (lib/config/api_config.dart)

```dart
class ApiConfig {
  static const String baseUrl = 'http://localhost:5159';
  static const String apiVersion = '/api';
}
```

## 🐛 Troubleshooting

### Backend không khởi động
```powershell
# Kiểm tra SQL Server LocalDB
sqllocaldb info

# Tạo lại database
dotnet ef database drop
dotnet ef database update
```

### Flutter compilation error
```powershell
# Clean build
flutter clean
flutter pub get
flutter run -d chrome
```

### CORS Error
Kiểm tra `Program.cs` đã cấu hình CORS cho `http://localhost:8080`

## 📊 Database Schema

### Các bảng chính
- **AspNetUsers**: Tài khoản người dùng
- **Members**: Thông tin hội viên
- **Courts**: Danh sách sân
- **Bookings**: Lịch đặt sân
- **Tournaments**: Giải đấu
- **TournamentRegistrations**: Đăng ký giải
- **WalletTransactions**: Giao dịch ví
- **News**: Tin tức

## 🎯 Tính năng nổi bật

### ✅ VietQR Integration
- QR code tự động tạo với số tiền và nội dung chuyển khoản
- Tích hợp thông tin ngân hàng thực tế
- Dynamic QR cập nhật theo số tiền nhập

### ✅ Realtime Notifications
- SignalR Hub cho thông báo tức thời
- Flutter Local Notifications
- Thông báo đặt sân, giải đấu, nạp tiền

### ✅ Auto Cleanup Service
- Background service tự động hủy booking Pending sau 5 phút
- Hoàn tiền tự động về ví

### ✅ Tournament Re-registration
- Cho phép đăng ký lại sau khi hủy
- Reuse registration record thay vì tạo mới
- Tránh duplicate entries

## 📝 License

This project is for educational purposes only.

## 👥 Contributors

- Sinh viên thực hiện: [Tên của bạn]
- Môn học: Mobile Application Development
- Năm học: 2025-2026

## 📞 Liên hệ

- Email: support@pickleballclub.com
- Website: https://pickleballclub.com

---

**Happy Coding! 🎾🚀**
