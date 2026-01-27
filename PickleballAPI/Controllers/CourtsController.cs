using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using PickleballAPI.Data;
using PickleballAPI.DTOs;
using PickleballAPI.Models;

namespace PickleballAPI.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
public class CourtsController : ControllerBase
{
    private readonly ApplicationDbContext _context;
    
    public CourtsController(ApplicationDbContext context)
    {
        _context = context;
    }
    
    [HttpGet]
    [AllowAnonymous]
    public async Task<ActionResult<IEnumerable<CourtDto>>> GetCourts()
    {
        var courts = await _context.Courts
            .Where(c => c.IsActive)
            .Select(c => new CourtDto
            {
                Id = c.Id,
                Name = c.Name,
                Description = c.Description,
                ImageUrl = c.ImageUrl,
                CourtType = c.CourtType,
                Status = c.Status,
                PricePerHour = c.PricePerHour,
                IsActive = c.IsActive
            })
            .ToListAsync();
        
        return Ok(courts);
    }
    
    [HttpGet("{id}")]
    [AllowAnonymous]
    public async Task<ActionResult<CourtDto>> GetCourt(int id)
    {
        var court = await _context.Courts.FindAsync(id);
        if (court == null)
            return NotFound();
        
        return Ok(new CourtDto
        {
            Id = court.Id,
            Name = court.Name,
            Description = court.Description,
            ImageUrl = court.ImageUrl,
            CourtType = court.CourtType,
            Status = court.Status,
            PricePerHour = court.PricePerHour,
            IsActive = court.IsActive
        });
    }
    
    [HttpPost]
    public async Task<ActionResult<CourtDto>> CreateCourt([FromBody] CreateCourtDto dto)
    {
        var court = new Court
        {
            Name = dto.Name,
            Description = dto.Description,
            ImageUrl = dto.ImageUrl,
            CourtType = dto.CourtType,
            PricePerHour = dto.PricePerHour,
            Status = "Available",
            IsActive = true,
            CreatedAt = DateTime.UtcNow
        };
        
        _context.Courts.Add(court);
        await _context.SaveChangesAsync();
        
        return CreatedAtAction(nameof(GetCourt), new { id = court.Id }, new CourtDto
        {
            Id = court.Id,
            Name = court.Name,
            Description = court.Description,
            ImageUrl = court.ImageUrl,
            CourtType = court.CourtType,
            Status = court.Status,
            PricePerHour = court.PricePerHour,
            IsActive = court.IsActive
        });
    }
    
    [HttpPut("{id}")]
    public async Task<IActionResult> UpdateCourt(int id, [FromBody] UpdateCourtDto dto)
    {
        var court = await _context.Courts.FindAsync(id);
        if (court == null)
            return NotFound();
        
        if (!string.IsNullOrEmpty(dto.Name))
            court.Name = dto.Name;
        if (dto.Description != null)
            court.Description = dto.Description;
        if (dto.ImageUrl != null)
            court.ImageUrl = dto.ImageUrl;
        if (!string.IsNullOrEmpty(dto.CourtType))
            court.CourtType = dto.CourtType;
        if (!string.IsNullOrEmpty(dto.Status))
            court.Status = dto.Status;
        if (dto.PricePerHour.HasValue)
            court.PricePerHour = dto.PricePerHour.Value;
        if (dto.IsActive.HasValue)
            court.IsActive = dto.IsActive.Value;
        
        court.UpdatedAt = DateTime.UtcNow;
        
        await _context.SaveChangesAsync();
        return NoContent();
    }
    
    [HttpDelete("{id}")]
    public async Task<IActionResult> DeleteCourt(int id)
    {
        var court = await _context.Courts.FindAsync(id);
        if (court == null)
            return NotFound();
        
        court.IsActive = false;
        court.UpdatedAt = DateTime.UtcNow;
        
        await _context.SaveChangesAsync();
        return NoContent();
    }
    
    [HttpGet("{id}/slots")]
    public async Task<ActionResult> GetAvailableSlots(int id, [FromQuery] DateTime? date)
    {
        var court = await _context.Courts.FindAsync(id);
        if (court == null || !court.IsActive)
            return NotFound();
        
        var targetDate = date ?? DateTime.Today;
        
        // Get existing bookings for this court on target date
        var existingBookings = await _context.Bookings
            .Where(b => b.CourtId == id && 
                       b.BookingDate.Date == targetDate.Date &&
                       b.Status != "Cancelled")
            .ToListAsync();
        
        // Generate time slots from 6 AM to 10 PM (every hour)
        var slots = new List<object>();
        for (int hour = 6; hour < 22; hour++)
        {
            var startTime = new TimeSpan(hour, 0, 0);
            var endTime = new TimeSpan(hour + 1, 0, 0);
            
            // Check if slot is available
            var isBooked = existingBookings.Any(b =>
                (startTime >= b.StartTime && startTime < b.EndTime) ||
                (endTime > b.StartTime && endTime <= b.EndTime) ||
                (startTime <= b.StartTime && endTime >= b.EndTime));
            
            slots.Add(new
            {
                id = $"{hour:D2}:00-{(hour + 1):D2}:00",
                startTime = $"{hour:D2}:00",
                endTime = $"{(hour + 1):D2}:00",
                isAvailable = !isBooked,
                price = court.PricePerHour,
                courtId = id
            });
        }
        
        return Ok(slots);
    }
}
