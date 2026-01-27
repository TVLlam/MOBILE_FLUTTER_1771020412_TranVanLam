using System.Security.Claims;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using PickleballAPI.Data;
using PickleballAPI.DTOs;
using PickleballAPI.Services;

namespace PickleballAPI.Controllers;

[ApiController]
[Route("api/[controller]")]
public class AuthController : ControllerBase
{
    private readonly IAuthService _authService;
    private readonly ApplicationDbContext _context;
    
    public AuthController(IAuthService authService, ApplicationDbContext context)
    {
        _authService = authService;
        _context = context;
    }
    
    [HttpPost("register")]
    public async Task<IActionResult> Register([FromBody] RegisterDto dto)
    {
        var result = await _authService.RegisterAsync(dto);
        if (result == null)
            return BadRequest(new { message = "Registration failed" });
        
        return Ok(result);
    }
    
    [HttpPost("login")]
    public async Task<IActionResult> Login([FromBody] LoginDto dto)
    {
        var result = await _authService.LoginAsync(dto);
        if (result == null)
            return Unauthorized(new { message = "Invalid credentials" });
        
        return Ok(result);
    }

    [HttpGet("me")]
    [Authorize]
    public async Task<IActionResult> GetMe()
    {
        var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);
        if (string.IsNullOrEmpty(userId))
            return Unauthorized();

        var user = await _context.Users
            .Include(u => u.Member)
            .FirstOrDefaultAsync(u => u.Id == userId);

        if (user == null)
            return NotFound();

        var response = new
        {
            id = user.Id,
            email = user.Email,
            fullName = user.FullName,
            role = user.Role,
            member = user.Member != null ? new
            {
                id = user.Member.Id,
                fullName = user.Member.FullName,
                email = user.Member.Email,
                phoneNumber = user.Member.PhoneNumber,
                avatarUrl = user.Member.AvatarUrl,
                membershipType = user.Member.MembershipType,
                walletBalance = user.Member.WalletBalance,
                isActive = user.Member.IsActive,
                joinedDate = user.Member.JoinedDate
            } : null
        };

        return Ok(response);
    }
}
