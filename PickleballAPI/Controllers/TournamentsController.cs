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
            IsActive = tournament.IsActive
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
}
