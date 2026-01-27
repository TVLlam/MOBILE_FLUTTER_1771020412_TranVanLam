using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;
using PickleballAPI.Models;

namespace PickleballAPI.Data;

public static class DbSeeder
{
    public static async Task SeedAsync(
        IServiceProvider serviceProvider,
        UserManager<ApplicationUser> userManager)
    {
        using var scope = serviceProvider.CreateScope();
        var context = scope.ServiceProvider.GetRequiredService<ApplicationDbContext>();
        
        // Seed Courts
        if (!await context.Courts.AnyAsync())
        {
            var courts = new[]
            {
                new Court
                {
                    Name = "Court 1 - Indoor",
                    Description = "Professional indoor court with climate control",
                    ImageUrl = "https://picsum.photos/400/300?random=1",
                    CourtType = "Indoor",
                    PricePerHour = 50000,
                    Status = "Available",
                    IsActive = true,
                    CreatedAt = DateTime.UtcNow
                },
                new Court
                {
                    Name = "Court 2 - Outdoor",
                    Description = "Outdoor court with natural lighting",
                    ImageUrl = "https://picsum.photos/400/300?random=2",
                    CourtType = "Outdoor",
                    PricePerHour = 35000,
                    Status = "Available",
                    IsActive = true,
                    CreatedAt = DateTime.UtcNow
                },
                new Court
                {
                    Name = "Court 3 - Premium",
                    Description = "Premium court with advanced facilities",
                    ImageUrl = "https://picsum.photos/400/300?random=3",
                    CourtType = "Indoor",
                    PricePerHour = 80000,
                    Status = "Available",
                    IsActive = true,
                    CreatedAt = DateTime.UtcNow
                },
                new Court
                {
                    Name = "Court 4 - Standard",
                    Description = "Standard court for practice",
                    ImageUrl = "https://picsum.photos/400/300?random=4",
                    CourtType = "Outdoor",
                    PricePerHour = 30000,
                    Status = "Available",
                    IsActive = true,
                    CreatedAt = DateTime.UtcNow
                }
            };
            
            await context.Courts.AddRangeAsync(courts);
            await context.SaveChangesAsync();
        }
        
        // Seed Tournaments
        if (!await context.Tournaments.AnyAsync())
        {
            var tournaments = new[]
            {
                new Tournament
                {
                    Name = "Spring Championship 2024",
                    Description = "Annual spring tournament for all skill levels",
                    ImageUrl = "https://picsum.photos/400/300?random=5",
                    StartDate = DateTime.UtcNow.AddDays(30),
                    EndDate = DateTime.UtcNow.AddDays(32),
                    RegistrationDeadline = DateTime.UtcNow.AddDays(20),
                    Format = "Singles",
                    Level = "Advanced",
                    MaxParticipants = 32,
                    CurrentParticipants = 0,
                    EntryFee = 200000,
                    PrizePool = 5000000,
                    Status = "Upcoming",
                    IsActive = true,
                    CreatedAt = DateTime.UtcNow
                },
                new Tournament
                {
                    Name = "Beginner's Cup",
                    Description = "Perfect for new players to compete",
                    ImageUrl = "https://picsum.photos/400/300?random=6",
                    StartDate = DateTime.UtcNow.AddDays(15),
                    EndDate = DateTime.UtcNow.AddDays(16),
                    RegistrationDeadline = DateTime.UtcNow.AddDays(10),
                    Format = "Doubles",
                    Level = "Beginner",
                    MaxParticipants = 16,
                    CurrentParticipants = 0,
                    EntryFee = 100000,
                    PrizePool = 1500000,
                    Status = "Upcoming",
                    IsActive = true,
                    CreatedAt = DateTime.UtcNow
                },
                new Tournament
                {
                    Name = "Summer Open 2024",
                    Description = "Major tournament with international players",
                    ImageUrl = "https://picsum.photos/400/300?random=7",
                    StartDate = DateTime.UtcNow.AddDays(60),
                    EndDate = DateTime.UtcNow.AddDays(65),
                    RegistrationDeadline = DateTime.UtcNow.AddDays(45),
                    Format = "Mixed",
                    Level = "Professional",
                    MaxParticipants = 64,
                    CurrentParticipants = 0,
                    EntryFee = 500000,
                    PrizePool = 20000000,
                    Status = "Upcoming",
                    IsActive = true,
                    CreatedAt = DateTime.UtcNow
                }
            };
            
            await context.Tournaments.AddRangeAsync(tournaments);
            await context.SaveChangesAsync();
        }
        
        // Seed Demo User and Members
        if (!await context.Users.AnyAsync())
        {
            // Admin user
            var adminUser = new ApplicationUser
            {
                Email = "admin@pickleball.com",
                UserName = "admin@pickleball.com",
                FullName = "Admin User",
                PhoneNumber = "0900000000",
                Role = "Admin",
                EmailConfirmed = true,
                CreatedAt = DateTime.UtcNow
            };
            
            await userManager.CreateAsync(adminUser, "Admin@123");
            
            var adminMember = new Member
            {
                UserId = adminUser.Id,
                FullName = "Admin User",
                Email = "admin@pickleball.com",
                PhoneNumber = "0900000000",
                DateOfBirth = new DateTime(1985, 1, 1),
                Gender = "Male",
                MembershipType = "Diamond",
                WalletBalance = 10000000,
                IsActive = true,
                JoinedDate = DateTime.UtcNow.AddYears(-2),
                CreatedAt = DateTime.UtcNow
            };
            
            await context.Members.AddAsync(adminMember);

            // Create 20 demo members
            var memberNames = new[]
            {
                "Nguyễn Văn A", "Trần Thị B", "Lê Văn C", "Phạm Thị D", "Hoàng Văn E",
                "Võ Thị F", "Đặng Văn G", "Bùi Thị H", "Dương Văn I", "Lý Thị K",
                "Ngô Văn L", "Vũ Thị M", "Đỗ Văn N", "Hồ Thị O", "Phan Văn P",
                "Trịnh Thị Q", "Mai Văn R", "Chu Thị S", "Tạ Văn T", "Đinh Thị U"
            };

            var membershipTypes = new[] { "Basic", "Silver", "Gold", "VIP", "Diamond" };
            var random = new Random();

            for (int i = 0; i < memberNames.Length; i++)
            {
                var email = $"member{i + 1}@pickleball.com";
                var user = new ApplicationUser
                {
                    Email = email,
                    UserName = email,
                    FullName = memberNames[i],
                    PhoneNumber = $"09{random.Next(10000000, 99999999)}",
                    Role = i < 2 ? "Referee" : "User",
                    EmailConfirmed = true,
                    CreatedAt = DateTime.UtcNow
                };

                await userManager.CreateAsync(user, "Member@123");

                var member = new Member
                {
                    UserId = user.Id,
                    FullName = memberNames[i],
                    Email = email,
                    PhoneNumber = user.PhoneNumber,
                    DateOfBirth = new DateTime(1990 + random.Next(0, 20), random.Next(1, 13), random.Next(1, 28)),
                    Gender = i % 2 == 0 ? "Male" : "Female",
                    MembershipType = membershipTypes[random.Next(membershipTypes.Length)],
                    WalletBalance = random.Next(2000000, 10000001),
                    IsActive = true,
                    JoinedDate = DateTime.UtcNow.AddMonths(-random.Next(1, 24)),
                    CreatedAt = DateTime.UtcNow
                };

                await context.Members.AddAsync(member);
            }

            // Quick login test user
            var testUser = new ApplicationUser
            {
                Email = "member@pickleball.com",
                UserName = "member@pickleball.com",
                FullName = "Test Member",
                PhoneNumber = "0900123456",
                Role = "User",
                EmailConfirmed = true,
                CreatedAt = DateTime.UtcNow
            };
            
            await userManager.CreateAsync(testUser, "Member@123");
            
            var testMember = new Member
            {
                UserId = testUser.Id,
                FullName = "Test Member",
                Email = "member@pickleball.com",
                PhoneNumber = "0900123456",
                DateOfBirth = new DateTime(1995, 6, 15),
                Gender = "Male",
                MembershipType = "Gold",
                WalletBalance = 5000000,
                IsActive = true,
                JoinedDate = DateTime.UtcNow.AddMonths(-6),
                CreatedAt = DateTime.UtcNow
            };
            
            await context.Members.AddAsync(testMember);
            
            // Original demo user
            var demoUser = new ApplicationUser
            {
                Email = "demo@pickleball.com",
                UserName = "demo@pickleball.com",
                FullName = "Demo User",
                PhoneNumber = "0123456789",
                Role = "User",
                EmailConfirmed = true,
                CreatedAt = DateTime.UtcNow
            };
            
            var result = await userManager.CreateAsync(demoUser, "Demo@123");
            
            if (result.Succeeded)
            {
                var member = new Member
                {
                    UserId = demoUser.Id,
                    FullName = "Demo User",
                    Email = "demo@pickleball.com",
                    PhoneNumber = "0123456789",
                    DateOfBirth = new DateTime(1990, 1, 1),
                    Gender = "Male",
                    MembershipType = "Premium",
                    JoinedDate = DateTime.UtcNow,
                    ExpiryDate = DateTime.UtcNow.AddYears(1),
                    IsActive = true,
                    WalletBalance = 1000000,
                    CreatedAt = DateTime.UtcNow
                };
                
                await context.Members.AddAsync(member);
                await context.SaveChangesAsync();
            }
        }
        
        // Seed News
        if (!await context.News.AnyAsync())
        {
            var newsItems = new[]
            {
                new News
                {
                    Title = "Chào mừng đến với CLB Pickleball!",
                    Content = "Chúng tôi rất vui mừng chào đón bạn đến với Câu lạc bộ Pickleball. Đây là nơi tuyệt vời để bạn rèn luyện sức khỏe, giao lưu và phát triển kỹ năng chơi Pickleball. Hãy tham gia các hoạt động và giải đấu của chúng tôi!",
                    ImageUrl = "https://picsum.photos/800/400?random=10",
                    IsPinned = true,
                    CreatedAt = DateTime.UtcNow.AddDays(-10),
                    UpdatedAt = DateTime.UtcNow.AddDays(-10)
                },
                new News
                {
                    Title = "Giải đấu mùa xuân 2024 sắp diễn ra",
                    Content = "Giải đấu Spring Championship 2024 sẽ diễn ra vào tháng tới với tổng giải thưởng lên đến 5 triệu đồng. Đây là cơ hội tuyệt vời để bạn thể hiện tài năng và giao lưu với các tay vợt khác. Đăng ký ngay hôm nay!",
                    ImageUrl = "https://picsum.photos/800/400?random=11",
                    IsPinned = true,
                    CreatedAt = DateTime.UtcNow.AddDays(-5),
                    UpdatedAt = DateTime.UtcNow.AddDays(-5)
                },
                new News
                {
                    Title = "Khuyến mãi đặc biệt cho hội viên mới",
                    Content = "Chào mừng các hội viên mới! Đăng ký gói hội viên Gold ngay hôm nay để nhận ưu đãi giảm 20% cho tháng đầu tiên. Ngoài ra còn tặng 2 giờ chơi miễn phí tại sân Premium.",
                    ImageUrl = "https://picsum.photos/800/400?random=12",
                    IsPinned = false,
                    CreatedAt = DateTime.UtcNow.AddDays(-3),
                    UpdatedAt = DateTime.UtcNow.AddDays(-3)
                },
                new News
                {
                    Title = "Lịch bảo trì sân định kỳ tháng 3",
                    Content = "Thông báo: Sân số 3 sẽ được bảo trì định kỳ từ ngày 15/3 đến 18/3. Trong thời gian này, sân sẽ tạm ngưng hoạt động. Quý hội viên vui lòng đặt sân khác. Xin cảm ơn!",
                    ImageUrl = "https://picsum.photos/800/400?random=13",
                    IsPinned = false,
                    CreatedAt = DateTime.UtcNow.AddDays(-2),
                    UpdatedAt = DateTime.UtcNow.AddDays(-2)
                },
                new News
                {
                    Title = "Mở lớp tập cho người mới bắt đầu",
                    Content = "CLB sẽ mở lớp học Pickleball cho người mới bắt đầu vào mỗi thứ 7 hàng tuần. Huấn luyện viên chuyên nghiệp sẽ hướng dẫn chi tiết từ cơ bản đến nâng cao. Học phí chỉ 500,000đ/tháng.",
                    ImageUrl = "https://picsum.photos/800/400?random=14",
                    IsPinned = false,
                    CreatedAt = DateTime.UtcNow.AddDays(-1),
                    UpdatedAt = DateTime.UtcNow.AddDays(-1)
                }
            };
            
            await context.News.AddRangeAsync(newsItems);
            await context.SaveChangesAsync();
        }
    }
}
