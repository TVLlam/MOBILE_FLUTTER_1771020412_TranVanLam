namespace PickleballAPI.DTOs;

public class WalletTransactionDto
{
    public int Id { get; set; }
    public int MemberId { get; set; }
    public string Type { get; set; } = string.Empty;
    public decimal Amount { get; set; }
    public decimal BalanceBefore { get; set; }
    public decimal BalanceAfter { get; set; }
    public string? Description { get; set; }
    public string? ReferenceId { get; set; }
    public string Status { get; set; } = string.Empty;
    public DateTime CreatedAt { get; set; }
}

public class DepositDto
{
    public decimal Amount { get; set; }
    public string? Description { get; set; }
}

public class WithdrawalDto
{
    public decimal Amount { get; set; }
    public string? Description { get; set; }
}
