namespace PickleballAPI.DTOs;

public class TournamentDto
{
    public int Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public string? Description { get; set; }
    public string? ImageUrl { get; set; }
    public DateTime StartDate { get; set; }
    public DateTime EndDate { get; set; }
    public DateTime RegistrationDeadline { get; set; }
    public string Format { get; set; } = string.Empty;
    public string Level { get; set; } = string.Empty;
    public int MaxParticipants { get; set; }
    public int CurrentParticipants { get; set; }
    public decimal EntryFee { get; set; }
    public decimal PrizePool { get; set; }
    public string Status { get; set; } = string.Empty;
    public bool IsActive { get; set; }
}

public class CreateTournamentDto
{
    public string Name { get; set; } = string.Empty;
    public string? Description { get; set; }
    public string? ImageUrl { get; set; }
    public DateTime StartDate { get; set; }
    public DateTime EndDate { get; set; }
    public DateTime RegistrationDeadline { get; set; }
    public string Format { get; set; } = "Singles";
    public string Level { get; set; } = "Beginner";
    public int MaxParticipants { get; set; }
    public decimal EntryFee { get; set; }
    public decimal PrizePool { get; set; }
}

public class TournamentRegistrationDto
{
    public int Id { get; set; }
    public int TournamentId { get; set; }
    public string TournamentName { get; set; } = string.Empty;
    public int MemberId { get; set; }
    public string MemberName { get; set; } = string.Empty;
    public int? PartnerId { get; set; }
    public string? PartnerName { get; set; }
    public DateTime RegistrationDate { get; set; }
    public string Status { get; set; } = string.Empty;
    public decimal AmountPaid { get; set; }
}

public class RegisterTournamentDto
{
    public int TournamentId { get; set; }
    public int? PartnerId { get; set; }
}
