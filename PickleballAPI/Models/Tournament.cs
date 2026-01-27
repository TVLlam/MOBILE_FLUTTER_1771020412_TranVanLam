using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace PickleballAPI.Models;

public class Tournament
{
    [Key]
    public int Id { get; set; }
    
    [Required]
    [MaxLength(200)]
    public string Name { get; set; } = string.Empty;
    
    [MaxLength(1000)]
    public string? Description { get; set; }
    
    public string? ImageUrl { get; set; }
    
    public DateTime StartDate { get; set; }
    
    public DateTime EndDate { get; set; }
    
    public DateTime RegistrationDeadline { get; set; }
    
    [Required]
    [MaxLength(50)]
    public string Format { get; set; } = "Singles"; // Singles, Doubles, Mixed
    
    [Required]
    [MaxLength(50)]
    public string Level { get; set; } = "Beginner";
    
    public int MaxParticipants { get; set; }
    
    public int CurrentParticipants { get; set; } = 0;
    
    [Column(TypeName = "decimal(18,2)")]
    public decimal EntryFee { get; set; }
    
    [Column(TypeName = "decimal(18,2)")]
    public decimal PrizePool { get; set; }
    
    [Required]
    [MaxLength(50)]
    public string Status { get; set; } = "Upcoming";
    
    public bool IsActive { get; set; } = true;
    
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    
    public DateTime? UpdatedAt { get; set; }
    
    // Navigation properties
    public ICollection<TournamentRegistration> Registrations { get; set; } = new List<TournamentRegistration>();
    public ICollection<Match> Matches { get; set; } = new List<Match>();
}
