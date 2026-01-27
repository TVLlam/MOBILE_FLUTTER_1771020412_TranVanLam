# Pickleball Management System - Tổng kết Dự án

## Tổng quan

Hệ thống quản lý câu lạc bộ pickleball hoàn chỉnh với Flutter frontend và ASP.NET Core backend.

## Cấu trúc Dự án

```
BT_TUAN8/
├── pickleball_app/              # Flutter Mobile App
│   ├── lib/
│   │   ├── config/              # API Configuration
│   │   ├── models/              # Data Models
│   │   ├── providers/           # Riverpod State Management
│   │   ├── services/            # Business Logic & API Services
│   │   ├── screens/             # UI Screens
│   │   └── widgets/             # Reusable Widgets
│   └── pubspec.yaml
│
├── PickleballAPI/               # ASP.NET Core Web API
│   ├── Controllers/             # API Controllers
│   ├── Data/                    # Database Context & Seeder
│   ├── DTOs/                    # Data Transfer Objects
│   ├── Models/                  # Entity Models
│   ├── Services/                # Business Services
│   ├── Migrations/              # EF Core Migrations
│   ├── Program.cs               # API Configuration
│   └── appsettings.json         # App Settings
│
└── INTEGRATION_GUIDE.md         # Integration Instructions
```

## Công nghệ sử dụng

### Frontend (Flutter)
- **Framework**: Flutter ^3.10.1
- **Language**: Dart ^3.0.3
- **State Management**: Riverpod 2.4.9
- **UI**: Material Design 3
- **HTTP Client**: http package
- **Navigation**: go_router 13.0.0
- **Icons**: font_awesome_flutter 10.6.0

### Backend (ASP.NET Core)
- **Framework**: .NET 8.0
- **Database**: SQL Server (LocalDB)
- **ORM**: Entity Framework Core 8.0.11
- **Authentication**: JWT Bearer + ASP.NET Identity
- **API Documentation**: Swagger/OpenAPI

## Tính năng đã Implement

### ✅ Authentication & Authorization
- [x] User registration with validation
- [x] Login with email/password
- [x] JWT token-based authentication
- [x] Password hashing with ASP.NET Identity
- [x] Token storage and auto-login

### ✅ Member Management
- [x] Member profile with wallet integration
- [x] Membership types (Basic, Premium, VIP)
- [x] Profile update
- [x] Avatar management

### ✅ Court Management
- [x] List all courts with filters
- [x] Court details with images
- [x] Court types (Indoor/Outdoor)
- [x] Real-time availability status
- [x] Price per hour display

### ✅ Booking System
- [x] Create court booking
- [x] View booking history
- [x] Cancel booking with refund
- [x] Booking conflict detection
- [x] Auto payment from wallet
- [x] Booking status tracking

### ✅ Wallet System
- [x] Wallet balance display
- [x] Deposit money
- [x] Withdraw money
- [x] Transaction history
- [x] Auto deduction for bookings
- [x] Refund on cancellation

### ✅ Tournament Management
- [x] List tournaments by status
- [x] Tournament details
- [x] Registration system
- [x] Entry fee handling
- [x] Different formats (Singles/Doubles/Mixed)
- [x] Skill levels (Beginner/Intermediate/Advanced)

### ✅ Database
- [x] Relational database design
- [x] Entity relationships
- [x] Migrations
- [x] Seed data
- [x] Data validation

## API Endpoints

### Authentication
```
POST /api/auth/register    - Register new user
POST /api/auth/login       - Login user
```

### Courts
```
GET    /api/courts         - Get all courts
GET    /api/courts/{id}    - Get court by ID
POST   /api/courts         - Create court
PUT    /api/courts/{id}    - Update court
DELETE /api/courts/{id}    - Delete court
```

### Bookings
```
GET    /api/bookings           - Get user bookings
GET    /api/bookings/{id}      - Get booking by ID
POST   /api/bookings           - Create booking
PATCH  /api/bookings/{id}/status - Update status
DELETE /api/bookings/{id}      - Cancel booking
```

### Wallet
```
GET  /api/wallet/balance       - Get balance
GET  /api/wallet/transactions  - Get transactions
POST /api/wallet/deposit       - Deposit money
POST /api/wallet/withdraw      - Withdraw money
```

### Tournaments
```
GET  /api/tournaments      - Get all tournaments
GET  /api/tournaments/{id} - Get tournament by ID
POST /api/tournaments      - Create tournament
```

## Database Schema

### Tables
1. **AspNetUsers** - User accounts (Identity)
2. **Members** - Member profiles
3. **Courts** - Pickleball courts
4. **Bookings** - Court reservations
5. **WalletTransactions** - Financial transactions
6. **Tournaments** - Tournament information
7. **TournamentRegistrations** - Tournament sign-ups
8. **Matches** - Tournament matches

### Relationships
- User 1:1 Member
- Member 1:N Bookings
- Court 1:N Bookings
- Member 1:N WalletTransactions
- Tournament 1:N TournamentRegistrations
- Member 1:N TournamentRegistrations

## Demo Data

### Demo Account
- Email: `demo@pickleball.com`
- Password: `Demo@123`
- Wallet: 1,000,000 VND
- Membership: Premium

### Courts (4)
- Court 1 - Indoor (50,000 VND/hour)
- Court 2 - Outdoor (35,000 VND/hour)
- Court 3 - Premium (80,000 VND/hour)
- Court 4 - Standard (30,000 VND/hour)

### Tournaments (3)
- Spring Championship 2024 (Advanced)
- Beginner's Cup (Beginner)
- Summer Open 2024 (Professional)

## Chạy Dự án

### Backend API
```bash
cd PickleballAPI
dotnet restore
dotnet ef database update
dotnet run
```
API chạy tại: `https://localhost:7000`

### Flutter App
```bash
cd pickleball_app
flutter pub get
flutter run
```

### Kiểm tra
1. Mở Swagger: `https://localhost:7000/swagger`
2. Test APIs trước khi chạy Flutter
3. Update API URL trong `api_config.dart` nếu cần
4. Run Flutter app và test tất cả features

## Business Logic

### Booking Rules
- Kiểm tra xung đột thời gian
- Tự động tính tiền theo giờ
- Trừ tiền wallet khi booking
- Hoàn tiền khi cancel
- Status: Pending → Confirmed → Completed/Cancelled

### Wallet Rules
- Balance = Sum(All Transactions)
- Transactions are immutable
- Deposit: Positive amount
- Withdrawal/Payment: Negative amount
- Minimum balance for bookings

### Tournament Rules
- Registration deadline before start date
- Max participants limit
- Entry fee deducted from wallet
- Status: Upcoming → Ongoing → Completed
- Different formats and levels

## Security Features

- Password hashing with PBKDF2
- JWT tokens with 30-day expiry
- Authorization on protected endpoints
- HTTPS in production
- Input validation on all forms
- SQL injection prevention via EF Core
- XSS prevention

## Performance Optimizations

- Database indexing on foreign keys
- Eager loading with Include()
- Async/await throughout
- Connection pooling
- CORS optimization
- Minimal API response sizes

## Testing

### Manual Testing Checklist
- [ ] Register new user
- [ ] Login/Logout
- [ ] View and update profile
- [ ] Browse courts
- [ ] Create booking
- [ ] Cancel booking with refund
- [ ] Deposit to wallet
- [ ] View transactions
- [ ] Browse tournaments
- [ ] Register for tournament

### Test Accounts
Create additional test accounts via registration or Swagger.

## Future Enhancements

### Potential Features
- [ ] SignalR for real-time notifications
- [ ] Push notifications
- [ ] QR code for check-in
- [ ] Rating and reviews
- [ ] Coach management
- [ ] Equipment rental
- [ ] Match scheduling
- [ ] Leaderboards
- [ ] Social features (friends, chat)
- [ ] Analytics dashboard
- [ ] Email notifications
- [ ] SMS verification
- [ ] Payment gateway integration
- [ ] Photo gallery
- [ ] News and events

### Technical Improvements
- [ ] Unit tests
- [ ] Integration tests
- [ ] CI/CD pipeline
- [ ] Docker containerization
- [ ] Cloud deployment (Azure/AWS)
- [ ] Redis caching
- [ ] Rate limiting
- [ ] Logging with Serilog
- [ ] Health checks
- [ ] API versioning

## Known Issues & Limitations

1. **HTTPS Certificate**: Development mode uses self-signed cert
2. **CORS**: Currently allows all origins (dev only)
3. **File Upload**: Avatar URLs are strings, not file uploads
4. **Real-time**: No SignalR implementation yet
5. **Payment**: Mock payment, no real gateway integration

## Troubleshooting

### API không chạy
- Kiểm tra .NET SDK version
- Kiểm tra SQL Server LocalDB
- Xem lỗi trong console

### Flutter không connect được API
- Kiểm tra API URL và port
- Kiểm tra HTTPS certificate
- Xem logs trong debug console

### Database errors
- Drop và recreate: `dotnet ef database drop`
- Apply migrations: `dotnet ef database update`

## Documentation

- [Backend README](PickleballAPI/README.md)
- [Integration Guide](INTEGRATION_GUIDE.md)
- [Bài kiểm tra](Bai%20kiem%20tra_Flutter.md)

## Author & Credits

Dự án được phát triển theo yêu cầu trong file "Bai kiem tra_Flutter.md"

### Technologies Credits
- Flutter Team
- Microsoft ASP.NET Core Team
- Riverpod
- Entity Framework Core
- Material Design

## License

Educational project - All rights reserved

---

**Status**: ✅ HOÀN THÀNH
**Last Updated**: 2024-01-27
**Version**: 1.0.0
