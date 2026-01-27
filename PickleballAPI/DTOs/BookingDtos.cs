namespace PickleballAPI.DTOs;

public class BookingDto
{
    public int Id { get; set; }
    public int MemberId { get; set; }
    public string MemberName { get; set; } = string.Empty;
    public int CourtId { get; set; }
    public string CourtName { get; set; } = string.Empty;
    public DateTime BookingDate { get; set; }
    public TimeSpan StartTime { get; set; }
    public TimeSpan EndTime { get; set; }
    public string Status { get; set; } = string.Empty;
    public decimal TotalAmount { get; set; }
    public string? Notes { get; set; }
    public DateTime CreatedAt { get; set; }
}

public class CreateBookingDto
{
    public int CourtId { get; set; }
    public DateTime BookingDate { get; set; }
    public TimeSpan StartTime { get; set; }
    public TimeSpan EndTime { get; set; }
    public string? Notes { get; set; }
}

public class UpdateBookingStatusDto
{
    public string Status { get; set; } = string.Empty;
}

public class CreateRecurringBookingDto
{
    public int CourtId { get; set; }
    public DateTime StartDate { get; set; }
    public DateTime EndDate { get; set; }
    public string StartTime { get; set; } = string.Empty;
    public string EndTime { get; set; } = string.Empty;
    public List<int> DaysOfWeek { get; set; } = new(); // 0=Sunday, 1=Monday, etc.
    public string? Notes { get; set; }
}
