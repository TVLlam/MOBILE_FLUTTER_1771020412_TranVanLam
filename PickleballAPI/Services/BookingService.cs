using Microsoft.EntityFrameworkCore;
using PickleballAPI.Data;
using PickleballAPI.DTOs;
using PickleballAPI.Models;

namespace PickleballAPI.Services;

public interface IBookingService
{
    Task<IEnumerable<BookingDto>> GetBookingsAsync(int? memberId = null);
    Task<BookingDto?> GetBookingByIdAsync(int id);
    Task<BookingDto?> CreateBookingAsync(int memberId, CreateBookingDto dto);
    Task<bool> UpdateBookingStatusAsync(int id, string status);
    Task<bool> CancelBookingAsync(int id);
}

public class BookingService : IBookingService
{
    private readonly ApplicationDbContext _context;
    private readonly IWalletService _walletService;
    
    public BookingService(ApplicationDbContext context, IWalletService walletService)
    {
        _context = context;
        _walletService = walletService;
    }
    
    public async Task<IEnumerable<BookingDto>> GetBookingsAsync(int? memberId = null)
    {
        var query = _context.Bookings
            .Include(b => b.Member)
            .Include(b => b.Court)
            .AsQueryable();
        
        if (memberId.HasValue)
            query = query.Where(b => b.MemberId == memberId.Value);
        
        return await query
            .OrderByDescending(b => b.CreatedAt)
            .Select(b => new BookingDto
            {
                Id = b.Id,
                MemberId = b.MemberId,
                MemberName = b.Member!.FullName,
                CourtId = b.CourtId,
                CourtName = b.Court!.Name,
                BookingDate = b.BookingDate,
                StartTime = b.StartTime,
                EndTime = b.EndTime,
                Status = b.Status,
                TotalAmount = b.TotalAmount,
                Notes = b.Notes,
                CreatedAt = b.CreatedAt
            })
            .ToListAsync();
    }
    
    public async Task<BookingDto?> GetBookingByIdAsync(int id)
    {
        var booking = await _context.Bookings
            .Include(b => b.Member)
            .Include(b => b.Court)
            .FirstOrDefaultAsync(b => b.Id == id);
        
        if (booking == null)
            return null;
        
        return new BookingDto
        {
            Id = booking.Id,
            MemberId = booking.MemberId,
            MemberName = booking.Member!.FullName,
            CourtId = booking.CourtId,
            CourtName = booking.Court!.Name,
            BookingDate = booking.BookingDate,
            StartTime = booking.StartTime,
            EndTime = booking.EndTime,
            Status = booking.Status,
            TotalAmount = booking.TotalAmount,
            Notes = booking.Notes,
            CreatedAt = booking.CreatedAt
        };
    }
    
    public async Task<BookingDto?> CreateBookingAsync(int memberId, CreateBookingDto dto)
    {
        var court = await _context.Courts.FindAsync(dto.CourtId);
        if (court == null || !court.IsActive)
            return null;
        
        // Check if court is available
        var existingBooking = await _context.Bookings
            .AnyAsync(b => 
                b.CourtId == dto.CourtId && 
                b.BookingDate.Date == dto.BookingDate.Date &&
                b.Status != "Cancelled" &&
                ((dto.StartTime >= b.StartTime && dto.StartTime < b.EndTime) ||
                 (dto.EndTime > b.StartTime && dto.EndTime <= b.EndTime) ||
                 (dto.StartTime <= b.StartTime && dto.EndTime >= b.EndTime)));
        
        if (existingBooking)
            return null;
        
        var hours = (dto.EndTime - dto.StartTime).TotalHours;
        var totalAmount = court.PricePerHour * (decimal)hours;
        
        // Check wallet balance
        var member = await _context.Members.FindAsync(memberId);
        if (member == null || member.WalletBalance < totalAmount)
            return null;
        
        var booking = new Booking
        {
            MemberId = memberId,
            CourtId = dto.CourtId,
            BookingDate = dto.BookingDate,
            StartTime = dto.StartTime,
            EndTime = dto.EndTime,
            Status = "Confirmed",
            TotalAmount = totalAmount,
            Notes = dto.Notes,
            CreatedAt = DateTime.UtcNow
        };
        
        _context.Bookings.Add(booking);
        await _context.SaveChangesAsync();
        
        // Deduct from wallet
        await _walletService.CreateTransactionAsync(memberId, new WalletTransaction
        {
            MemberId = memberId,
            Type = "Payment",
            Amount = -totalAmount,
            BalanceBefore = member.WalletBalance,
            BalanceAfter = member.WalletBalance - totalAmount,
            Description = $"Payment for court booking #{booking.Id}",
            ReferenceId = $"BOOKING-{booking.Id}",
            Status = "Completed"
        });
        
        return await GetBookingByIdAsync(booking.Id);
    }
    
    public async Task<bool> UpdateBookingStatusAsync(int id, string status)
    {
        var booking = await _context.Bookings.FindAsync(id);
        if (booking == null)
            return false;
        
        booking.Status = status;
        booking.UpdatedAt = DateTime.UtcNow;
        
        await _context.SaveChangesAsync();
        return true;
    }
    
    public async Task<bool> CancelBookingAsync(int id)
    {
        var booking = await _context.Bookings
            .Include(b => b.Member)
            .FirstOrDefaultAsync(b => b.Id == id);
        
        if (booking == null || booking.Status == "Cancelled")
            return false;
        
        booking.Status = "Cancelled";
        booking.UpdatedAt = DateTime.UtcNow;
        
        // Refund to wallet
        if (booking.Member != null)
        {
            await _walletService.CreateTransactionAsync(booking.MemberId, new WalletTransaction
            {
                MemberId = booking.MemberId,
                Type = "Deposit",
                Amount = booking.TotalAmount,
                BalanceBefore = booking.Member.WalletBalance,
                BalanceAfter = booking.Member.WalletBalance + booking.TotalAmount,
                Description = $"Refund for cancelled booking #{booking.Id}",
                ReferenceId = $"REFUND-{booking.Id}",
                Status = "Completed"
            });
        }
        
        await _context.SaveChangesAsync();
        return true;
    }
}
