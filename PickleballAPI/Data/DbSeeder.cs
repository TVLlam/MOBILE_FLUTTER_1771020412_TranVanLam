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
        
        // Seed Demo User
        if (!await context.Users.AnyAsync())
        {
            var demoUser = new ApplicationUser
            {
                Email = "demo@pickleball.com",
                UserName = "demo@pickleball.com",
                FullName = "Demo User",
                PhoneNumber = "0123456789",
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
    }
}
