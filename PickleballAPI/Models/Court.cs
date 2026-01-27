using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace PickleballAPI.Models;

public class Court
{
    [Key]
    public int Id { get; set; }
    
    [Required]
    [MaxLength(100)]
    public string Name { get; set; } = string.Empty;
    
    [MaxLength(500)]
    public string? Description { get; set; }
    
    public string? ImageUrl { get; set; }
    
    [Required]
    [MaxLength(50)]
    public string CourtType { get; set; } = "Indoor";
    
    [Required]
    [MaxLength(50)]
    public string Status { get; set; } = "Available";
    
    [Column(TypeName = "decimal(18,2)")]
    public decimal PricePerHour { get; set; }
    
    public bool IsActive { get; set; } = true;
    
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    
    public DateTime? UpdatedAt { get; set; }
    
    // Navigation properties
    public ICollection<Booking> Bookings { get; set; } = new List<Booking>();
}
