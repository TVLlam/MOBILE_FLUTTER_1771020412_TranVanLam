# Hướng dẫn Integration Flutter App với Backend API

## 1. Chạy Backend API

### Bước 1: Chạy API Server
```bash
cd PickleballAPI
dotnet run
```

### Bước 2: Kiểm tra URL và Port
- Sau khi chạy, console sẽ hiển thị URLs:
  ```
  Now listening on: https://localhost:7000
  Now listening on: http://localhost:5000
  ```
- Ghi nhớ HTTPS port (thường là 7000 hoặc 7xxx)

### Bước 3: Test API với Swagger
- Mở browser: `https://localhost:7000/swagger`
- Swagger UI sẽ hiển thị tất cả endpoints
- Test các API như login, register, get courts, etc.

## 2. Cấu hình Flutter App

### Bước 1: Update API Config
Mở file `pickleball_app/lib/config/api_config.dart`:

```dart
class ApiConfig {
  // Cập nhật port này theo port của API server
  static const String baseUrl = 'https://localhost:7000';
  ...
}
```

### Bước 2: Cài đặt Packages (nếu cần)
```bash
cd pickleball_app
flutter pub get
```

### Bước 3: Chạy Flutter App
```bash
flutter run
```

## 3. Test Integration

### Test Authentication
1. Mở app Flutter
2. Click "Sign Up" hoặc dùng demo account:
   - Email: `demo@pickleball.com`
   - Password: `Demo@123`
3. Login thành công sẽ nhận được JWT token

### Test Courts
1. Sau khi login, vào màn hình Courts
2. App sẽ load danh sách sân từ API
3. Thử đặt sân (booking)

### Test Wallet
1. Vào màn hình Wallet
2. Kiểm tra balance (demo account có 1,000,000 VND)
3. Thử deposit hoặc xem transaction history

### Test Tournaments
1. Vào màn hình Tournaments
2. Xem danh sách giải đấu
3. Thử đăng ký tham gia

## 4. Xử lý HTTPS Certificate (Development)

### Android
Nếu gặp lỗi SSL certificate:
1. Thêm vào `android/app/src/main/AndroidManifest.xml`:
```xml
<application
    android:usesCleartextTraffic="true"
    ...>
```

2. Hoặc dùng HTTP thay vì HTTPS trong development:
```dart
static const String baseUrl = 'http://localhost:5000';
```

### iOS
Thêm vào `ios/Runner/Info.plist`:
```xml
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <true/>
</dict>
```

## 5. Update Services để gọi Real API

Hiện tại Flutter app đang dùng mock services. Cần update để gọi real API:

### Example: Update AuthService
```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class AuthService {
  Future<AuthResponse?> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.loginUrl),
        headers: ApiConfig.headers(),
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return AuthResponse.fromJson(data);
      }
      return null;
    } catch (e) {
      print('Login error: $e');
      return null;
    }
  }
  
  Future<AuthResponse?> register(RegisterData data) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.registerUrl),
        headers: ApiConfig.headers(),
        body: jsonEncode(data.toJson()),
      );
      
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return AuthResponse.fromJson(responseData);
      }
      return null;
    } catch (e) {
      print('Register error: $e');
      return null;
    }
  }
}
```

## 6. Debug Tips

### Kiểm tra API đang chạy
```bash
# Windows PowerShell
Test-NetConnection localhost -Port 7000
```

### Xem API logs
- Console của `dotnet run` sẽ hiển thị mọi request
- Kiểm tra status codes, request body, response

### Debug Flutter network calls
1. Thêm logging:
```dart
print('Request URL: ${ApiConfig.loginUrl}');
print('Request body: ${jsonEncode(data)}');
print('Response status: ${response.statusCode}');
print('Response body: ${response.body}');
```

2. Sử dụng Flutter DevTools network tab

### Common Issues

**Issue 1: Connection refused**
- Đảm bảo API đang chạy
- Kiểm tra port đúng
- Kiểm tra firewall

**Issue 2: SSL Certificate error**
- Dùng HTTP thay vì HTTPS trong development
- Hoặc configure certificate như hướng dẫn ở trên

**Issue 3: CORS error**
- Backend đã config CORS cho development
- Nếu vẫn lỗi, kiểm tra CORS policy trong Program.cs

**Issue 4: 401 Unauthorized**
- Kiểm tra JWT token có được gửi trong header không
- Token có hết hạn không (expire sau 30 ngày)

## 7. Production Deployment

### Backend
1. Update connection string cho production database
2. Update JWT secret key
3. Configure CORS cho specific origins
4. Deploy to Azure/AWS/etc.

### Flutter
1. Update `baseUrl` to production API URL
2. Remove debug code
3. Build release APK/IPA
4. Deploy to Play Store/App Store

## 8. Testing Checklist

- [ ] Register new user
- [ ] Login with demo account
- [ ] View courts list
- [ ] Create booking
- [ ] Cancel booking
- [ ] View wallet balance
- [ ] Deposit money
- [ ] View transactions
- [ ] View tournaments
- [ ] Register for tournament
- [ ] View profile
- [ ] Update profile

## 9. API Response Examples

### Login Success
```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "userId": "123e4567-e89b-12d3-a456-426614174000",
  "email": "demo@pickleball.com",
  "fullName": "Demo User",
  "member": {
    "id": 1,
    "fullName": "Demo User",
    "email": "demo@pickleball.com",
    "walletBalance": 1000000,
    ...
  }
}
```

### Get Courts
```json
[
  {
    "id": 1,
    "name": "Court 1 - Indoor",
    "description": "Professional indoor court",
    "pricePerHour": 50000,
    "status": "Available",
    ...
  },
  ...
]
```

### Create Booking
```json
{
  "id": 1,
  "memberId": 1,
  "courtId": 1,
  "bookingDate": "2024-02-01T00:00:00",
  "startTime": "09:00:00",
  "endTime": "11:00:00",
  "totalAmount": 100000,
  "status": "Confirmed"
}
```
