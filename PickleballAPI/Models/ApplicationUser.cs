using Microsoft.AspNetCore.Identity;

namespace PickleballAPI.Models;

public class ApplicationUser : IdentityUser
{
    public string? FullName { get; set; }
    public string? AvatarUrl { get; set; }
    public string Role { get; set; } = "User";
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    public DateTime? UpdatedAt { get; set; }
    
    // Navigation properties
    public Member? Member { get; set; }
}
