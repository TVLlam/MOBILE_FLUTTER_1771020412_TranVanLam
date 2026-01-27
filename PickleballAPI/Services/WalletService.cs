using Microsoft.EntityFrameworkCore;
using PickleballAPI.Data;
using PickleballAPI.DTOs;
using PickleballAPI.Models;

namespace PickleballAPI.Services;

public interface IWalletService
{
    Task<decimal> GetBalanceAsync(int memberId);
    Task<IEnumerable<WalletTransactionDto>> GetTransactionsAsync(int memberId);
    Task<WalletTransactionDto?> DepositAsync(int memberId, DepositDto dto);
    Task<WalletTransactionDto?> WithdrawAsync(int memberId, WithdrawalDto dto);
    Task CreateTransactionAsync(int memberId, WalletTransaction transaction);
}

public class WalletService : IWalletService
{
    private readonly ApplicationDbContext _context;
    
    public WalletService(ApplicationDbContext context)
    {
        _context = context;
    }
    
    public async Task<decimal> GetBalanceAsync(int memberId)
    {
        var member = await _context.Members.FindAsync(memberId);
        return member?.WalletBalance ?? 0;
    }
    
    public async Task<IEnumerable<WalletTransactionDto>> GetTransactionsAsync(int memberId)
    {
        return await _context.WalletTransactions
            .Where(wt => wt.MemberId == memberId)
            .OrderByDescending(wt => wt.CreatedAt)
            .Select(wt => new WalletTransactionDto
            {
                Id = wt.Id,
                MemberId = wt.MemberId,
                Type = wt.Type,
                Amount = wt.Amount,
                BalanceBefore = wt.BalanceBefore,
                BalanceAfter = wt.BalanceAfter,
                Description = wt.Description,
                ReferenceId = wt.ReferenceId,
                Status = wt.Status,
                CreatedAt = wt.CreatedAt
            })
            .ToListAsync();
    }
    
    public async Task<WalletTransactionDto?> DepositAsync(int memberId, DepositDto dto)
    {
        var member = await _context.Members.FindAsync(memberId);
        if (member == null || dto.Amount <= 0)
            return null;
        
        var transaction = new WalletTransaction
        {
            MemberId = memberId,
            Type = "Deposit",
            Amount = dto.Amount,
            BalanceBefore = member.WalletBalance,
            BalanceAfter = member.WalletBalance + dto.Amount,
            Description = dto.Description ?? "Wallet deposit",
            ReferenceId = $"DEP-{Guid.NewGuid():N}",
            Status = "Completed",
            CreatedAt = DateTime.UtcNow
        };
        
        member.WalletBalance += dto.Amount;
        member.UpdatedAt = DateTime.UtcNow;
        
        _context.WalletTransactions.Add(transaction);
        await _context.SaveChangesAsync();
        
        return new WalletTransactionDto
        {
            Id = transaction.Id,
            MemberId = transaction.MemberId,
            Type = transaction.Type,
            Amount = transaction.Amount,
            BalanceBefore = transaction.BalanceBefore,
            BalanceAfter = transaction.BalanceAfter,
            Description = transaction.Description,
            ReferenceId = transaction.ReferenceId,
            Status = transaction.Status,
            CreatedAt = transaction.CreatedAt
        };
    }
    
    public async Task<WalletTransactionDto?> WithdrawAsync(int memberId, WithdrawalDto dto)
    {
        var member = await _context.Members.FindAsync(memberId);
        if (member == null || dto.Amount <= 0 || member.WalletBalance < dto.Amount)
            return null;
        
        var transaction = new WalletTransaction
        {
            MemberId = memberId,
            Type = "Withdrawal",
            Amount = -dto.Amount,
            BalanceBefore = member.WalletBalance,
            BalanceAfter = member.WalletBalance - dto.Amount,
            Description = dto.Description ?? "Wallet withdrawal",
            ReferenceId = $"WDR-{Guid.NewGuid():N}",
            Status = "Completed",
            CreatedAt = DateTime.UtcNow
        };
        
        member.WalletBalance -= dto.Amount;
        member.UpdatedAt = DateTime.UtcNow;
        
        _context.WalletTransactions.Add(transaction);
        await _context.SaveChangesAsync();
        
        return new WalletTransactionDto
        {
            Id = transaction.Id,
            MemberId = transaction.MemberId,
            Type = transaction.Type,
            Amount = transaction.Amount,
            BalanceBefore = transaction.BalanceBefore,
            BalanceAfter = transaction.BalanceAfter,
            Description = transaction.Description,
            ReferenceId = transaction.ReferenceId,
            Status = transaction.Status,
            CreatedAt = transaction.CreatedAt
        };
    }
    
    public async Task CreateTransactionAsync(int memberId, WalletTransaction transaction)
    {
        var member = await _context.Members.FindAsync(memberId);
        if (member == null)
            return;
        
        member.WalletBalance = transaction.BalanceAfter;
        member.UpdatedAt = DateTime.UtcNow;
        
        _context.WalletTransactions.Add(transaction);
        await _context.SaveChangesAsync();
    }
}
