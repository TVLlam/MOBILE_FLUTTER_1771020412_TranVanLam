using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace PickleballAPI.Models;

public class Match
{
    [Key]
    public int Id { get; set; }
    
    [Required]
    public int TournamentId { get; set; }
    
    [MaxLength(100)]
    public string? Round { get; set; }
    
    public int? CourtId { get; set; }
    
    public DateTime? ScheduledTime { get; set; }
    
    public int? Team1Player1Id { get; set; }
    
    public int? Team1Player2Id { get; set; }
    
    public int? Team2Player1Id { get; set; }
    
    public int? Team2Player2Id { get; set; }
    
    public int? Team1Score { get; set; }
    
    public int? Team2Score { get; set; }
    
    public int? WinnerTeam { get; set; }
    
    [Required]
    [MaxLength(50)]
    public string Status { get; set; } = "Scheduled";
    
    public DateTime? StartTime { get; set; }
    
    public DateTime? EndTime { get; set; }
    
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    
    public DateTime? UpdatedAt { get; set; }
    
    // Navigation properties
    [ForeignKey("TournamentId")]
    public Tournament? Tournament { get; set; }
    
    [ForeignKey("CourtId")]
    public Court? Court { get; set; }
}
