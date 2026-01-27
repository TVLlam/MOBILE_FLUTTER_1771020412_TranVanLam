using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace PickleballAPI.Models;

public class WalletTransaction
{
    [Key]
    public int Id { get; set; }
    
    [Required]
    public int MemberId { get; set; }
    
    [Required]
    [MaxLength(50)]
    public string Type { get; set; } = string.Empty; // Deposit, Withdrawal, Payment
    
    [Column(TypeName = "decimal(18,2)")]
    public decimal Amount { get; set; }
    
    [Column(TypeName = "decimal(18,2)")]
    public decimal BalanceBefore { get; set; }
    
    [Column(TypeName = "decimal(18,2)")]
    public decimal BalanceAfter { get; set; }
    
    [MaxLength(500)]
    public string? Description { get; set; }
    
    [MaxLength(100)]
    public string? ReferenceId { get; set; }
    
    [Required]
    [MaxLength(50)]
    public string Status { get; set; } = "Completed";
    
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    
    // Navigation properties
    [ForeignKey("MemberId")]
    public Member? Member { get; set; }
}
