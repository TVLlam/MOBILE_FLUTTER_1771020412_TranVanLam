using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace PickleballAPI.Models;

public class Booking
{
    [Key]
    public int Id { get; set; }
    
    [Required]
    public int MemberId { get; set; }
    
    [Required]
    public int CourtId { get; set; }
    
    [Required]
    public DateTime BookingDate { get; set; }
    
    [Required]
    public TimeSpan StartTime { get; set; }
    
    [Required]
    public TimeSpan EndTime { get; set; }
    
    [Required]
    [MaxLength(50)]
    public string Status { get; set; } = "Pending";
    
    [Column(TypeName = "decimal(18,2)")]
    public decimal TotalAmount { get; set; }
    
    [MaxLength(500)]
    public string? Notes { get; set; }
    
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    
    public DateTime? UpdatedAt { get; set; }
    
    // Navigation properties
    [ForeignKey("MemberId")]
    public Member? Member { get; set; }
    
    [ForeignKey("CourtId")]
    public Court? Court { get; set; }
}
