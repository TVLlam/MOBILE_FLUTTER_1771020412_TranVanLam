# Pickleball Management System - Backend API

ASP.NET Core Web API cho hệ thống quản lý câu lạc bộ pickleball.

## Công nghệ

- **Framework**: ASP.NET Core 8.0 Web API
- **Database**: SQL Server (LocalDB)
- **ORM**: Entity Framework Core 8.0.11
- **Authentication**: JWT Bearer + ASP.NET Identity
- **Architecture**: Repository Pattern + Service Layer

## Cấu trúc dự án

```
PickleballAPI/
├── Controllers/          # API Controllers
│   ├── AuthController.cs
│   ├── BookingsController.cs
│   ├── CourtsController.cs
│   ├── TournamentsController.cs
│   └── WalletController.cs
├── Data/                # Database Context & Seeder
│   ├── ApplicationDbContext.cs
│   └── DbSeeder.cs
├── DTOs/                # Data Transfer Objects
│   ├── AuthDtos.cs
│   ├── BookingDtos.cs
│   ├── CourtDtos.cs
│   ├── TournamentDtos.cs
│   └── WalletDtos.cs
├── Models/              # Database Models
│   ├── ApplicationUser.cs
│   ├── Booking.cs
│   ├── Court.cs
│   ├── Match.cs
│   ├── Member.cs
│   ├── Tournament.cs
│   ├── TournamentRegistration.cs
│   └── WalletTransaction.cs
├── Services/            # Business Logic
│   ├── AuthService.cs
│   ├── BookingService.cs
│   └── WalletService.cs
└── Migrations/          # EF Core Migrations
```

## Database Schema

### Tables
- **AspNetUsers**: ASP.NET Identity users
- **Members**: Member profiles linked to users
- **Courts**: Pickleball courts
- **Bookings**: Court bookings
- **WalletTransactions**: Wallet transactions
- **Tournaments**: Tournament information
- **TournamentRegistrations**: Tournament registrations
- **Matches**: Tournament matches

## API Endpoints

### Authentication
- `POST /api/auth/register` - Register new user
- `POST /api/auth/login` - Login user

### Courts
- `GET /api/courts` - Get all courts
- `GET /api/courts/{id}` - Get court by ID
- `POST /api/courts` - Create court (requires auth)
- `PUT /api/courts/{id}` - Update court (requires auth)
- `DELETE /api/courts/{id}` - Delete court (requires auth)

### Bookings
- `GET /api/bookings` - Get user's bookings (requires auth)
- `GET /api/bookings/{id}` - Get booking by ID (requires auth)
- `POST /api/bookings` - Create booking (requires auth)
- `PATCH /api/bookings/{id}/status` - Update booking status (requires auth)
- `DELETE /api/bookings/{id}` - Cancel booking (requires auth)

### Wallet
- `GET /api/wallet/balance` - Get wallet balance (requires auth)
- `GET /api/wallet/transactions` - Get transaction history (requires auth)
- `POST /api/wallet/deposit` - Deposit money (requires auth)
- `POST /api/wallet/withdraw` - Withdraw money (requires auth)

### Tournaments
- `GET /api/tournaments` - Get all tournaments
- `GET /api/tournaments/{id}` - Get tournament by ID
- `POST /api/tournaments` - Create tournament (requires auth)

## Cài đặt và Chạy

### Yêu cầu
- .NET 8.0 SDK
- SQL Server hoặc SQL Server LocalDB

### Các bước

1. **Restore packages**:
   ```bash
   cd PickleballAPI
   dotnet restore
   ```

2. **Update connection string** trong `appsettings.json` nếu cần:
   ```json
   {
     "ConnectionStrings": {
       "DefaultConnection": "Server=(localdb)\\mssqllocaldb;Database=PickleballDB;Trusted_Connection=True;MultipleActiveResultSets=true"
     }
   }
   ```

3. **Apply migrations** (đã tạo database):
   ```bash
   dotnet ef database update
   ```

4. **Run API**:
   ```bash
   dotnet run
   ```

5. **Truy cập Swagger UI**:
   - Development: https://localhost:7xxx/swagger
   - Xem port trong console output

## Demo Account

Hệ thống đã seed sẵn tài khoản demo:

- **Email**: demo@pickleball.com
- **Password**: Demo@123
- **Wallet Balance**: 1,000,000 VND

## Seed Data

Database được seed với:
- 4 Courts (Indoor & Outdoor)
- 3 Tournaments (Different levels)
- 1 Demo user with Premium membership

## JWT Configuration

JWT settings trong `appsettings.json`:
```json
{
  "Jwt": {
    "Key": "YourSuperSecretKeyThatIsAtLeast32CharactersLong!",
    "Issuer": "PickleballAPI",
    "Audience": "PickleballApp"
  }
}
```

## Entity Framework Commands

```bash
# Add migration
dotnet ef migrations add MigrationName

# Update database
dotnet ef database update

# Remove last migration
dotnet ef migrations remove

# Drop database
dotnet ef database drop
```

## Security

- Passwords are hashed using ASP.NET Identity
- JWT tokens expire after 30 days
- Password requirements:
  - Minimum 6 characters
  - At least 1 digit
  - At least 1 uppercase letter
  - At least 1 lowercase letter

## CORS Policy

API cho phép tất cả origins trong development mode. Cần configure lại cho production.

## Business Rules

### Bookings
- Kiểm tra xung đột thời gian đặt sân
- Tự động trừ tiền từ wallet khi đặt sân
- Hoàn tiền khi hủy booking

### Wallet
- Transactions are immutable (không thể sửa/xóa)
- Balance is calculated from transactions
- Negative amounts for withdrawals/payments

### Tournaments
- Registration deadline must be before start date
- Entry fee is deducted from wallet
- Current participants updated automatically

## Error Handling

API trả về standard HTTP status codes:
- `200 OK` - Success
- `201 Created` - Resource created
- `204 No Content` - Success with no content
- `400 Bad Request` - Invalid request
- `401 Unauthorized` - Authentication required
- `404 Not Found` - Resource not found
- `500 Internal Server Error` - Server error
