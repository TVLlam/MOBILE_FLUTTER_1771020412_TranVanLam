using System.Security.Claims;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using PickleballAPI.Data;
using PickleballAPI.DTOs;
using PickleballAPI.Services;

namespace PickleballAPI.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
public class BookingsController : ControllerBase
{
    private readonly IBookingService _bookingService;
    private readonly ApplicationDbContext _context;
    
    public BookingsController(IBookingService bookingService, ApplicationDbContext context)
    {
        _bookingService = bookingService;
        _context = context;
    }
    
    [HttpGet]
    public async Task<ActionResult<IEnumerable<BookingDto>>> GetBookings()
    {
        var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);
        var member = await _context.Members.FirstOrDefaultAsync(m => m.UserId == userId);
        
        if (member == null)
            return NotFound();
        
        var bookings = await _bookingService.GetBookingsAsync(member.Id);
        return Ok(bookings);
    }
    
    [HttpGet("my-bookings")]
    public async Task<ActionResult<IEnumerable<BookingDto>>> GetMyBookings()
    {
        var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);
        var member = await _context.Members.FirstOrDefaultAsync(m => m.UserId == userId);
        
        if (member == null)
            return NotFound();
        
        var bookings = await _bookingService.GetBookingsAsync(member.Id);
        return Ok(bookings);
    }
    
    [HttpGet("{id}")]
    public async Task<ActionResult<BookingDto>> GetBooking(int id)
    {
        var booking = await _bookingService.GetBookingByIdAsync(id);
        if (booking == null)
            return NotFound();
        
        return Ok(booking);
    }
    
    [HttpPost]
    public async Task<ActionResult<BookingDto>> CreateBooking([FromBody] CreateBookingDto dto)
    {
        var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);
        var member = await _context.Members.FirstOrDefaultAsync(m => m.UserId == userId);
        
        if (member == null)
            return NotFound();
        
        var booking = await _bookingService.CreateBookingAsync(member.Id, dto);
        if (booking == null)
            return BadRequest(new { message = "Unable to create booking" });
        
        return CreatedAtAction(nameof(GetBooking), new { id = booking.Id }, booking);
    }
    
    [HttpPatch("{id}/status")]
    public async Task<IActionResult> UpdateBookingStatus(int id, [FromBody] UpdateBookingStatusDto dto)
    {
        var result = await _bookingService.UpdateBookingStatusAsync(id, dto.Status);
        if (!result)
            return NotFound();
        
        return NoContent();
    }
    
    [HttpDelete("{id}")]
    public async Task<IActionResult> CancelBooking(int id)
    {
        var result = await _bookingService.CancelBookingAsync(id);
        if (!result)
            return NotFound();
        
        return NoContent();
    }

    [HttpGet("calendar")]
    public async Task<ActionResult<IEnumerable<BookingDto>>> GetCalendar(
        [FromQuery] DateTime? from,
        [FromQuery] DateTime? to)
    {
        var startDate = from ?? DateTime.Today;
        var endDate = to ?? DateTime.Today.AddDays(30);

        var bookings = await _context.Bookings
            .Include(b => b.Member)
            .Include(b => b.Court)
            .Where(b => b.BookingDate >= startDate && b.BookingDate <= endDate)
            .OrderBy(b => b.BookingDate)
            .ThenBy(b => b.StartTime)
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

        return Ok(bookings);
    }

    [HttpPost("recurring")]
    public async Task<ActionResult<IEnumerable<BookingDto>>> CreateRecurringBooking(
        [FromBody] CreateRecurringBookingDto dto)
    {
        var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);
        var member = await _context.Members.FirstOrDefaultAsync(m => m.UserId == userId);
        
        if (member == null)
            return NotFound(new { message = "Member not found" });

        // Check if member is VIP
        if (member.MembershipType != "VIP" && member.MembershipType != "Gold" && member.MembershipType != "Diamond")
            return BadRequest(new { message = "Only VIP members can create recurring bookings" });

        var bookings = new List<Models.Booking>();
        var currentDate = dto.StartDate;

        while (currentDate <= dto.EndDate)
        {
            // Check if day of week matches
            if (dto.DaysOfWeek.Contains((int)currentDate.DayOfWeek))
            {
                var court = await _context.Courts.FindAsync(dto.CourtId);
                if (court == null)
                    continue;

                var startTime = TimeSpan.Parse(dto.StartTime);
                var endTime = TimeSpan.Parse(dto.EndTime);
                var duration = endTime - startTime;
                var totalAmount = court.PricePerHour * ((decimal)duration.TotalHours);

                // Check for conflicts
                var hasConflict = await _context.Bookings.AnyAsync(b =>
                    b.CourtId == dto.CourtId &&
                    b.BookingDate == currentDate &&
                    b.Status != "Cancelled" &&
                    ((b.StartTime < endTime && b.EndTime > startTime)));

                if (!hasConflict && member.WalletBalance >= totalAmount)
                {
                    var booking = new Models.Booking
                    {
                        MemberId = member.Id,
                        CourtId = dto.CourtId,
                        BookingDate = currentDate,
                        StartTime = startTime,
                        EndTime = endTime,
                        Status = "Confirmed",
                        TotalAmount = totalAmount,
                        Notes = dto.Notes,
                        CreatedAt = DateTime.UtcNow
                    };

                    bookings.Add(booking);
                    member.WalletBalance -= totalAmount;

                    // Create transaction
                    _context.WalletTransactions.Add(new Models.WalletTransaction
                    {
                        MemberId = member.Id,
                        Type = "Payment",
                        Amount = -totalAmount,
                        BalanceBefore = member.WalletBalance + totalAmount,
                        BalanceAfter = member.WalletBalance,
                        Description = $"Recurring booking - {court.Name} on {currentDate:dd/MM/yyyy}",
                        Status = "Completed",
                        CreatedAt = DateTime.UtcNow
                    });
                }
            }

            currentDate = currentDate.AddDays(1);
        }

        if (bookings.Count == 0)
            return BadRequest(new { message = "No bookings could be created. Check conflicts or insufficient balance." });

        _context.Bookings.AddRange(bookings);
        await _context.SaveChangesAsync();

        var bookingDtos = bookings.Select(b => new BookingDto
        {
            Id = b.Id,
            MemberId = b.MemberId,
            MemberName = member.FullName,
            CourtId = b.CourtId,
            BookingDate = b.BookingDate,
            StartTime = b.StartTime,
            EndTime = b.EndTime,
            Status = b.Status,
            TotalAmount = b.TotalAmount,
            Notes = b.Notes,
            CreatedAt = b.CreatedAt
        }).ToList();

        return Ok(bookingDtos);
    }
}
