using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace PickleballAPI.Models;

public class TournamentRegistration
{
    [Key]
    public int Id { get; set; }
    
    [Required]
    public int TournamentId { get; set; }
    
    [Required]
    public int MemberId { get; set; }
    
    public int? PartnerId { get; set; }
    
    public DateTime RegistrationDate { get; set; } = DateTime.UtcNow;
    
    [Required]
    [MaxLength(50)]
    public string Status { get; set; } = "Pending";
    
    [Column(TypeName = "decimal(18,2)")]
    public decimal AmountPaid { get; set; }
    
    [MaxLength(100)]
    public string? PaymentReference { get; set; }
    
    public DateTime? PaymentDate { get; set; }
    
    // Navigation properties
    [ForeignKey("TournamentId")]
    public Tournament? Tournament { get; set; }
    
    [ForeignKey("MemberId")]
    public Member? Member { get; set; }
}
