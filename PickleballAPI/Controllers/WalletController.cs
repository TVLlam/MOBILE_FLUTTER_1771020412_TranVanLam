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
[Authorize]
public class WalletController : ControllerBase
{
    private readonly IWalletService _walletService;
    private readonly ApplicationDbContext _context;
    
    public WalletController(IWalletService walletService, ApplicationDbContext context)
    {
        _walletService = walletService;
        _context = context;
    }
    
    [HttpGet("balance")]
    public async Task<ActionResult<decimal>> GetBalance()
    {
        var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);
        var member = await _context.Members.FirstOrDefaultAsync(m => m.UserId == userId);
        
        if (member == null)
            return NotFound();
        
        var balance = await _walletService.GetBalanceAsync(member.Id);
        return Ok(new { balance });
    }
    
    [HttpGet("transactions")]
    public async Task<ActionResult<IEnumerable<WalletTransactionDto>>> GetTransactions()
    {
        var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);
        var member = await _context.Members.FirstOrDefaultAsync(m => m.UserId == userId);
        
        if (member == null)
            return NotFound();
        
        var transactions = await _walletService.GetTransactionsAsync(member.Id);
        return Ok(transactions);
    }
    
    [HttpPost("deposit")]
    public async Task<ActionResult<WalletTransactionDto>> Deposit([FromBody] DepositDto dto)
    {
        var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);
        var member = await _context.Members.FirstOrDefaultAsync(m => m.UserId == userId);
        
        if (member == null)
            return NotFound();
        
        var transaction = await _walletService.DepositAsync(member.Id, dto);
        if (transaction == null)
            return BadRequest(new { message = "Deposit failed" });
        
        return Ok(transaction);
    }
    
    [HttpPost("withdraw")]
    public async Task<ActionResult<WalletTransactionDto>> Withdraw([FromBody] WithdrawalDto dto)
    {
        var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);
        var member = await _context.Members.FirstOrDefaultAsync(m => m.UserId == userId);
        
        if (member == null)
            return NotFound();
        
        var transaction = await _walletService.WithdrawAsync(member.Id, dto);
        if (transaction == null)
            return BadRequest(new { message = "Insufficient balance or invalid amount" });
        
        return Ok(transaction);
    }
}
