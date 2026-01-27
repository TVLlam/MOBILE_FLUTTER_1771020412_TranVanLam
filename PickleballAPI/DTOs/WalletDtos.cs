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

public class ApproveDepositDto
{
    public bool Approved { get; set; }
    public string? Reason { get; set; }
}

public class UpdateMatchResultDto
{
    public int Score1 { get; set; }
    public int Score2 { get; set; }
    public string? Details { get; set; }
}

public class UpdateMatchStatusDto
{
    public string Status { get; set; } = string.Empty;
}
