using System.Security.Claims;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using PickleballAPI.Data;
using PickleballAPI.DTOs;
using PickleballAPI.Models;

namespace PickleballAPI.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
public class TournamentsController : ControllerBase
{
    private readonly ApplicationDbContext _context;
    
    public TournamentsController(ApplicationDbContext context)
    {
        _context = context;
    }
    
    [HttpGet]
    [AllowAnonymous]
    public async Task<ActionResult<IEnumerable<TournamentDto>>> GetTournaments()
    {
        var tournaments = await _context.Tournaments
            .Where(t => t.IsActive)
            .Select(t => new TournamentDto
            {
                Id = t.Id,
                Name = t.Name,
                Description = t.Description,
                ImageUrl = t.ImageUrl,
                StartDate = t.StartDate,
                EndDate = t.EndDate,
                RegistrationDeadline = t.RegistrationDeadline,
                Format = t.Format,
                Level = t.Level,
                MaxParticipants = t.MaxParticipants,
                CurrentParticipants = t.CurrentParticipants,
                EntryFee = t.EntryFee,
                PrizePool = t.PrizePool,
                Status = t.Status,
                IsActive = t.IsActive
            })
            .ToListAsync();
        
        return Ok(tournaments);
    }
    
    [HttpGet("{id}")]
    [AllowAnonymous]
    public async Task<ActionResult<TournamentDto>> GetTournament(int id)
    {
        var tournament = await _context.Tournaments.FindAsync(id);
        if (tournament == null)
            return NotFound();
        
        // Check if current user is registered
        bool isRegistered = false;
        var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);
        if (!string.IsNullOrEmpty(userId))
        {
            var member = await _context.Members.FirstOrDefaultAsync(m => m.UserId == userId);
            if (member != null)
            {
                isRegistered = await _context.TournamentRegistrations
                    .AnyAsync(r => r.TournamentId == id && r.MemberId == member.Id);
            }
        }
        
        return Ok(new TournamentDto
        {
            Id = tournament.Id,
            Name = tournament.Name,
            Description = tournament.Description,
            ImageUrl = tournament.ImageUrl,
            StartDate = tournament.StartDate,
            EndDate = tournament.EndDate,
            RegistrationDeadline = tournament.RegistrationDeadline,
            Format = tournament.Format,
            Level = tournament.Level,
            MaxParticipants = tournament.MaxParticipants,
            CurrentParticipants = tournament.CurrentParticipants,
            EntryFee = tournament.EntryFee,
            PrizePool = tournament.PrizePool,
            Status = tournament.Status,
            IsActive = tournament.IsActive,
            IsRegistered = isRegistered
        });
    }
    
    [HttpPost]
    public async Task<ActionResult<TournamentDto>> CreateTournament([FromBody] CreateTournamentDto dto)
    {
        var tournament = new Tournament
        {
            Name = dto.Name,
            Description = dto.Description,
            ImageUrl = dto.ImageUrl,
            StartDate = dto.StartDate,
            EndDate = dto.EndDate,
            RegistrationDeadline = dto.RegistrationDeadline,
            Format = dto.Format,
            Level = dto.Level,
            MaxParticipants = dto.MaxParticipants,
            EntryFee = dto.EntryFee,
            PrizePool = dto.PrizePool,
            Status = "Upcoming",
            IsActive = true,
            CreatedAt = DateTime.UtcNow
        };
        
        _context.Tournaments.Add(tournament);
        await _context.SaveChangesAsync();
        
        return CreatedAtAction(nameof(GetTournament), new { id = tournament.Id }, new TournamentDto
        {
            Id = tournament.Id,
            Name = tournament.Name,
            Description = tournament.Description,
            ImageUrl = tournament.ImageUrl,
            StartDate = tournament.StartDate,
            EndDate = tournament.EndDate,
            RegistrationDeadline = tournament.RegistrationDeadline,
            Format = tournament.Format,
            Level = tournament.Level,
            MaxParticipants = tournament.MaxParticipants,
            CurrentParticipants = tournament.CurrentParticipants,
            EntryFee = tournament.EntryFee,
            PrizePool = tournament.PrizePool,
            Status = tournament.Status,
            IsActive = tournament.IsActive
        });
    }

    [HttpPost("{id}/join")]
    public async Task<IActionResult> JoinTournament(int id)
    {
        var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);
        var member = await _context.Members.FirstOrDefaultAsync(m => m.UserId == userId);

        if (member == null)
            return NotFound(new { message = "Member not found" });

        var tournament = await _context.Tournaments
            .Include(t => t.Registrations)
            .FirstOrDefaultAsync(t => t.Id == id);

        if (tournament == null)
            return NotFound(new { message = "Tournament not found" });

        if (tournament.Status != "Upcoming" && tournament.Status != "Open")
            return BadRequest(new { message = "Tournament is not open for registration" });

        if (tournament.RegistrationDeadline < DateTime.UtcNow)
            return BadRequest(new { message = "Registration deadline has passed" });

        if (tournament.CurrentParticipants >= tournament.MaxParticipants)
            return BadRequest(new { message = "Tournament is full" });

        var existingRegistration = await _context.TournamentRegistrations
            .FirstOrDefaultAsync(r => r.TournamentId == id && r.MemberId == member.Id);

        // Check if already registered with active status (not cancelled)
        if (existingRegistration != null && existingRegistration.Status != "Cancelled")
            return BadRequest(new { message = "Already registered for this tournament" });

        if (member.WalletBalance < tournament.EntryFee)
            return BadRequest(new { message = "Insufficient balance" });

        // Deduct entry fee
        var balanceBefore = member.WalletBalance;
        member.WalletBalance -= tournament.EntryFee;

        // Reuse existing registration if it was cancelled, otherwise create new one
        TournamentRegistration registration;
        if (existingRegistration != null && existingRegistration.Status == "Cancelled")
        {
            // Reactivate cancelled registration
            existingRegistration.Status = "Confirmed";
            existingRegistration.RegistrationDate = DateTime.UtcNow;
            existingRegistration.AmountPaid = tournament.EntryFee;
            existingRegistration.PaymentDate = DateTime.UtcNow;
            registration = existingRegistration;
        }
        else
        {
            // Create new registration
            registration = new TournamentRegistration
            {
                TournamentId = id,
                MemberId = member.Id,
                RegistrationDate = DateTime.UtcNow,
                Status = "Confirmed",
                AmountPaid = tournament.EntryFee,
                PaymentDate = DateTime.UtcNow
            };
            _context.TournamentRegistrations.Add(registration);
        }

        // Create transaction
        _context.WalletTransactions.Add(new WalletTransaction
        {
            MemberId = member.Id,
            Type = "Payment",
            Amount = -tournament.EntryFee,
            BalanceBefore = balanceBefore,
            BalanceAfter = member.WalletBalance,
            Description = $"Entry fee for tournament: {tournament.Name}",
            ReferenceId = id.ToString(),
            Status = "Completed",
            CreatedAt = DateTime.UtcNow
        });

        tournament.CurrentParticipants++;
        await _context.SaveChangesAsync();

        return Ok(new { message = "Successfully joined tournament" });
    }

    [HttpPost("{id}/cancel")]
    public async Task<IActionResult> CancelRegistration(int id)
    {
        var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);
        var member = await _context.Members.FirstOrDefaultAsync(m => m.UserId == userId);

        if (member == null)
            return NotFound(new { message = "Member not found" });

        var tournament = await _context.Tournaments.FindAsync(id);
        if (tournament == null)
            return NotFound(new { message = "Tournament not found" });

        var registration = await _context.TournamentRegistrations
            .FirstOrDefaultAsync(r => r.TournamentId == id && r.MemberId == member.Id);

        if (registration == null)
            return BadRequest(new { message = "You are not registered for this tournament" });

        if (registration.Status == "Cancelled")
            return BadRequest(new { message = "Registration already cancelled" });

        // Check if tournament has started
        if (tournament.Status != "Upcoming" && tournament.Status != "Open" && tournament.Status != "Registering")
            return BadRequest(new { message = "Cannot cancel registration after tournament has started" });

        // Calculate refund (50% of entry fee)
        var refundAmount = tournament.EntryFee * 0.5m;
        var balanceBefore = member.WalletBalance;
        member.WalletBalance += refundAmount;

        // Update registration status
        registration.Status = "Cancelled";

        // Create refund transaction
        _context.WalletTransactions.Add(new WalletTransaction
        {
            MemberId = member.Id,
            Type = "Refund",
            Amount = refundAmount,
            BalanceBefore = balanceBefore,
            BalanceAfter = member.WalletBalance,
            Description = $"Refund 50% for cancelled tournament: {tournament.Name}",
            ReferenceId = id.ToString(),
            Status = "Completed",
            CreatedAt = DateTime.UtcNow
        });

        // Decrease participant count
        if (tournament.CurrentParticipants > 0)
            tournament.CurrentParticipants--;

        await _context.SaveChangesAsync();

        return Ok(new 
        { 
            message = "Registration cancelled successfully. 50% refund has been credited to your wallet.",
            refundAmount = refundAmount,
            newBalance = member.WalletBalance
        });
    }

    [HttpPost("{id}/generate-schedule")]
    [Authorize(Roles = "Admin")]
    public async Task<IActionResult> GenerateSchedule(int id)
    {
        var tournament = await _context.Tournaments
            .Include(t => t.Registrations)
                .ThenInclude(r => r.Member)
            .FirstOrDefaultAsync(t => t.Id == id);

        if (tournament == null)
            return NotFound(new { message = "Tournament not found" });

        if (tournament.Registrations.Count < 2)
            return BadRequest(new { message = "Not enough participants" });

        // Clear existing matches
        var existingMatches = await _context.Matches
            .Where(m => m.TournamentId == id)
            .ToListAsync();
        _context.Matches.RemoveRange(existingMatches);

        var participants = tournament.Registrations.OrderBy(_ => Guid.NewGuid()).ToList();
        var matches = new List<Match>();
        var matchDate = tournament.StartDate;

        if (tournament.Format == "Singles" || tournament.Format == "Doubles")
        {
            // Knockout format
            int round = 1;
            var roundParticipants = participants.ToList();

            while (roundParticipants.Count > 1)
            {
                for (int i = 0; i < roundParticipants.Count; i += 2)
                {
                    if (i + 1 < roundParticipants.Count)
                    {
                        var match = new Match
                        {
                            TournamentId = id,
                            Team1Player1Id = roundParticipants[i].MemberId,
                            Team2Player1Id = roundParticipants[i + 1].MemberId,
                            ScheduledTime = matchDate.AddHours(matches.Count),
                            Status = "Scheduled",
                            Round = round.ToString(),
                            CreatedAt = DateTime.UtcNow
                        };
                        matches.Add(match);
                    }
                }

                // Prepare for next round (half the participants)
                roundParticipants = roundParticipants.Take(roundParticipants.Count / 2).ToList();
                round++;
                matchDate = matchDate.AddDays(1);
            }
        }
        else // Round Robin
        {
            // Everyone plays everyone
            for (int i = 0; i < participants.Count; i++)
            {
                for (int j = i + 1; j < participants.Count; j++)
                {
                    var match = new Match
                    {
                        TournamentId = id,
                        Team1Player1Id = participants[i].MemberId,
                        Team2Player1Id = participants[j].MemberId,
                        ScheduledTime = matchDate.AddHours(matches.Count % 8),
                        Status = "Scheduled",
                        Round = "1",
                        CreatedAt = DateTime.UtcNow
                    };
                    matches.Add(match);

                    if (matches.Count % 8 == 0)
                        matchDate = matchDate.AddDays(1);
                }
            }
        }

        _context.Matches.AddRange(matches);
        tournament.Status = "Ongoing";
        await _context.SaveChangesAsync();

        return Ok(new { message = $"Generated {matches.Count} matches", matchCount = matches.Count });
    }
}
