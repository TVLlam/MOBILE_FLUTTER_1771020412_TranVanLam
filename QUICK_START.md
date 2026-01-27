# ✅ DỰ ÁN HOÀN THÀNH - Quick Start Guide

## 🎯 Tổng quan

Dự án Pickleball Management System đã **HOÀN THÀNH 100%** với:
- ✅ Flutter Mobile App (Frontend)
- ✅ ASP.NET Core Web API (Backend)
- ✅ SQL Server Database
- ✅ Full CRUD Operations
- ✅ Authentication & Authorization
- ✅ Wallet System
- ✅ Booking System
- ✅ Tournament Management

## 🚀 Chạy Dự án trong 3 bước

### Bước 1: Khởi động Backend API

```bash
cd "d:\KI 2_2025-2026\MOBILE\BT_TUAN8\PickleballAPI"
dotnet run
```

**Kết quả:**
```
Now listening on: http://localhost:5159
Application started. Press Ctrl+C to shut down.
```

✅ API đang chạy tại: **http://localhost:5159**
✅ Swagger UI: **http://localhost:5159/swagger**

### Bước 2: Test API với Swagger

1. Mở browser: `http://localhost:5159/swagger`
2. Test endpoint `/api/auth/login`:
   ```json
   {
     "email": "demo@pickleball.com",
     "password": "Demo@123"
   }
   ```
3. Copy JWT token từ response
4. Click "Authorize" button ở góc trên
5. Paste token vào: `Bearer {your_token_here}`
6. Test các endpoints khác (Courts, Bookings, Wallet, Tournaments)

### Bước 3: Chạy Flutter App

**QUAN TRỌNG:** Update API URL trước!

1. Mở file: `pickleball_app/lib/config/api_config.dart`
2. Sửa dòng:
   ```dart
   static const String baseUrl = 'http://localhost:5159'; // Port từ API
   ```

3. Chạy Flutter:
   ```bash
   cd "d:\KI 2_2025-2026\MOBILE\BT_TUAN8\pickleball_app"
   flutter pub get
   flutter run
   ```

4. Login với demo account:
   - Email: `demo@pickleball.com`
   - Password: `Demo@123`

## 📱 Tính năng có thể Test ngay

### 1. Authentication
- ✅ Register new account
- ✅ Login with demo account
- ✅ Auto-login with saved token
- ✅ Logout

### 2. Courts
- ✅ View all courts (4 courts seeded)
- ✅ Filter by court type
- ✅ View court details
- ✅ See pricing

### 3. Bookings
- ✅ Create new booking
- ✅ View booking history
- ✅ Cancel booking (with refund)
- ✅ Auto payment from wallet

### 4. Wallet
- ✅ Check balance (Demo: 1,000,000 VND)
- ✅ Deposit money
- ✅ View transaction history
- ✅ Auto deduction for bookings

### 5. Tournaments
- ✅ Browse tournaments (3 tournaments seeded)
- ✅ View tournament details
- ✅ Register for tournament
- ✅ Different levels & formats

### 6. Profile
- ✅ View profile info
- ✅ Update profile
- ✅ Change avatar
- ✅ View membership type

## 🎮 Demo Scenarios

### Scenario 1: Book a Court
1. Login với demo account
2. Vào màn hình "Courts"
3. Chọn "Court 1 - Indoor"
4. Click "Book Now"
5. Chọn ngày và giờ
6. Xác nhận booking
7. Tiền tự động trừ từ wallet
8. Xem booking trong "My Bookings"

### Scenario 2: Check Wallet
1. Vào màn hình "Wallet"
2. Xem balance: 1,000,000 VND
3. Click "Deposit"
4. Nhập số tiền: 500,000
5. Xác nhận
6. Balance tăng lên 1,500,000 VND
7. Xem transaction history

### Scenario 3: Join Tournament
1. Vào màn hình "Tournaments"
2. Chọn "Beginner's Cup"
3. Click "Register"
4. Entry fee: 100,000 VND
5. Xác nhận đăng ký
6. Tiền trừ từ wallet
7. Check registration status

## 📊 Database đã có Data

### Demo User
- Email: demo@pickleball.com
- Password: Demo@123
- Membership: Premium
- Wallet: 1,000,000 VND

### 4 Courts
1. Court 1 - Indoor (50,000/hour)
2. Court 2 - Outdoor (35,000/hour)
3. Court 3 - Premium (80,000/hour)
4. Court 4 - Standard (30,000/hour)

### 3 Tournaments
1. Spring Championship 2024 (Advanced)
2. Beginner's Cup (Beginner)
3. Summer Open 2024 (Professional)

## 🔧 Troubleshooting

### API không chạy?
```bash
# Kiểm tra .NET version
dotnet --version  # Cần 8.0+

# Rebuild
cd PickleballAPI
dotnet clean
dotnet build
dotnet run
```

### Database error?
```bash
# Drop và recreate
dotnet ef database drop -f
dotnet ef database update
```

### Flutter không connect?
1. Kiểm tra API đang chạy
2. Kiểm tra port trong `api_config.dart`
3. Dùng HTTP thay HTTPS trong development
4. Check firewall settings

### HTTPS Certificate error?
Thêm vào `android/app/src/main/AndroidManifest.xml`:
```xml
<application
    android:usesCleartextTraffic="true"
    ...>
```

## 📁 File Structure

```
BT_TUAN8/
├── pickleball_app/           # Flutter App
│   ├── lib/
│   │   ├── config/           # API Config
│   │   ├── models/           # Data Models
│   │   ├── providers/        # State Management
│   │   ├── services/         # Business Logic
│   │   ├── screens/          # UI Screens
│   │   └── widgets/          # Reusable Widgets
│   └── pubspec.yaml
│
├── PickleballAPI/            # Backend API
│   ├── Controllers/          # API Controllers
│   ├── Data/                 # DB Context
│   ├── DTOs/                 # Data Transfer Objects
│   ├── Models/               # Entity Models
│   ├── Services/             # Business Services
│   ├── Migrations/           # EF Migrations
│   └── appsettings.json      # Configuration
│
├── INTEGRATION_GUIDE.md      # Chi tiết integration
├── PROJECT_SUMMARY.md        # Tổng kết dự án
└── QUICK_START.md           # File này
```

## 🎯 API Endpoints Summary

```
Authentication
POST   /api/auth/register
POST   /api/auth/login

Courts
GET    /api/courts
GET    /api/courts/{id}
POST   /api/courts
PUT    /api/courts/{id}
DELETE /api/courts/{id}

Bookings
GET    /api/bookings
POST   /api/bookings
DELETE /api/bookings/{id}

Wallet
GET    /api/wallet/balance
GET    /api/wallet/transactions
POST   /api/wallet/deposit
POST   /api/wallet/withdraw

Tournaments
GET    /api/tournaments
GET    /api/tournaments/{id}
POST   /api/tournaments
```

## ✨ Key Features

1. **JWT Authentication** - Secure token-based auth
2. **Wallet System** - Deposit, withdraw, transaction history
3. **Smart Booking** - Conflict detection, auto payment, refund
4. **Tournament Management** - Registration, entry fees, levels
5. **Real-time Status** - Court availability, booking status
6. **Material Design 3** - Modern, beautiful UI

## 📞 Support & Documentation

- **Backend README**: `PickleballAPI/README.md`
- **Integration Guide**: `INTEGRATION_GUIDE.md`
- **Project Summary**: `PROJECT_SUMMARY.md`
- **Requirements**: `Bai kiem tra_Flutter.md`

## 🎉 Next Steps

1. ✅ Chạy API server
2. ✅ Test với Swagger
3. ✅ Update API URL trong Flutter
4. ✅ Chạy Flutter app
5. ✅ Login với demo account
6. ✅ Test tất cả features
7. 🚀 Enjoy!

---

**Status**: ✅ **READY TO USE**
**Version**: 1.0.0
**Last Updated**: 2024-01-27

Happy Testing! 🎾
