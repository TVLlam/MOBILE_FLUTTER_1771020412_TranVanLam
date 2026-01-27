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

    [HttpPut("admin/approve/{transactionId}")]
    [Authorize(Roles = "Admin,Treasurer")]
    public async Task<IActionResult> ApproveDeposit(int transactionId, [FromBody] ApproveDepositDto dto)
    {
        var transaction = await _context.WalletTransactions
            .Include(t => t.Member)
            .FirstOrDefaultAsync(t => t.Id == transactionId);

        if (transaction == null)
            return NotFound(new { message = "Transaction not found" });

        if (transaction.Type != "Deposit")
            return BadRequest(new { message = "Only deposit transactions can be approved" });

        if (transaction.Status != "Pending")
            return BadRequest(new { message = "Transaction is not pending" });

        if (dto.Approved)
        {
            // Approve and add balance
            var balanceBefore = transaction.Member!.WalletBalance;
            transaction.Member.WalletBalance += transaction.Amount;
            
            transaction.BalanceBefore = balanceBefore;
            transaction.BalanceAfter = transaction.Member.WalletBalance;
            transaction.Status = "Completed";
            transaction.Description = (transaction.Description ?? "Deposit") + " - Approved by admin";
        }
        else
        {
            // Reject
            transaction.Status = "Rejected";
            transaction.Description = (transaction.Description ?? "Deposit") + $" - Rejected: {dto.Reason}";
        }

        await _context.SaveChangesAsync();

        return Ok(new { 
            message = dto.Approved ? "Deposit approved" : "Deposit rejected",
            transaction = new WalletTransactionDto
            {
                Id = transaction.Id,
                MemberId = transaction.MemberId,
                Type = transaction.Type,
                Amount = transaction.Amount,
                BalanceBefore = transaction.BalanceBefore,
                BalanceAfter = transaction.BalanceAfter,
                Description = transaction.Description,
                Status = transaction.Status,
                CreatedAt = transaction.CreatedAt
            }
        });
    }

    [HttpGet("admin/pending")]
    [Authorize(Roles = "Admin,Treasurer")]
    public async Task<ActionResult<IEnumerable<object>>> GetPendingDeposits()
    {
        var pending = await _context.WalletTransactions
            .Include(t => t.Member)
            .Where(t => t.Type == "Deposit" && t.Status == "Pending")
            .OrderByDescending(t => t.CreatedAt)
            .Select(t => new
            {
                id = t.Id,
                memberId = t.MemberId,
                memberName = t.Member!.FullName,
                amount = t.Amount,
                description = t.Description,
                createdAt = t.CreatedAt
            })
            .ToListAsync();

        return Ok(pending);
    }
}
