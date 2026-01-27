namespace PickleballAPI.DTOs;

public class CourtDto
{
    public int Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public string? Description { get; set; }
    public string? ImageUrl { get; set; }
    public string CourtType { get; set; } = string.Empty;
    public string Status { get; set; } = string.Empty;
    public decimal PricePerHour { get; set; }
    public bool IsActive { get; set; }
}

public class CreateCourtDto
{
    public string Name { get; set; } = string.Empty;
    public string? Description { get; set; }
    public string? ImageUrl { get; set; }
    public string CourtType { get; set; } = "Indoor";
    public decimal PricePerHour { get; set; }
}

public class UpdateCourtDto
{
    public string? Name { get; set; }
    public string? Description { get; set; }
    public string? ImageUrl { get; set; }
    public string? CourtType { get; set; }
    public string? Status { get; set; }
    public decimal? PricePerHour { get; set; }
    public bool? IsActive { get; set; }
}
