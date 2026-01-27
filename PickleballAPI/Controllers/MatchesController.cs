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
public class MatchesController : ControllerBase
{
    private readonly ApplicationDbContext _context;

    public MatchesController(ApplicationDbContext context)
    {
        _context = context;
    }

    [HttpGet]
    public async Task<ActionResult<IEnumerable<object>>> GetMatches([FromQuery] int? tournamentId)
    {
        var query = _context.Matches.AsQueryable();

        if (tournamentId.HasValue)
            query = query.Where(m => m.TournamentId == tournamentId.Value);

        var matches = await query
            .Include(m => m.Tournament)
            .OrderBy(m => m.ScheduledTime)
            .Select(m => new
            {
                id = m.Id,
                tournamentId = m.TournamentId,
                tournamentName = m.Tournament != null ? m.Tournament.Name : null,
                round = m.Round,
                team1_player1Id = m.Team1Player1Id,
                team1_player2Id = m.Team1Player2Id,
                team2_player1Id = m.Team2Player1Id,
                team2_player2Id = m.Team2Player2Id,
                score1 = m.Team1Score,
                score2 = m.Team2Score,
                winnerId = m.WinnerTeam,
                scheduledTime = m.ScheduledTime,
                startTime = m.StartTime,
                endTime = m.EndTime,
                status = m.Status,
                courtId = m.CourtId
            })
            .ToListAsync();

        return Ok(matches);
    }

    [HttpGet("{id}")]
    public async Task<ActionResult<object>> GetMatch(int id)
    {
        var match = await _context.Matches
            .Include(m => m.Tournament)
            .FirstOrDefaultAsync(m => m.Id == id);

        if (match == null)
            return NotFound();

        return Ok(new
        {
            id = match.Id,
            tournamentId = match.TournamentId,
            tournamentName = match.Tournament?.Name,
            round = match.Round,
            team1_player1Id = match.Team1Player1Id,
            team1_player2Id = match.Team1Player2Id,
            team2_player1Id = match.Team2Player1Id,
            team2_player2Id = match.Team2Player2Id,
            score1 = match.Team1Score,
            score2 = match.Team2Score,
            winnerId = match.WinnerTeam,
            scheduledTime = match.ScheduledTime,
            startTime = match.StartTime,
            endTime = match.EndTime,
            status = match.Status,
            courtId = match.CourtId
        });
    }

    [HttpPost("{id}/result")]
    [Authorize(Roles = "Admin,Referee")]
    public async Task<IActionResult> UpdateResult(int id, [FromBody] UpdateMatchResultDto dto)
    {
        var match = await _context.Matches
            .Include(m => m.Tournament)
            .FirstOrDefaultAsync(m => m.Id == id);

        if (match == null)
            return NotFound();

        if (match.Status == "Finished")
            return BadRequest(new { message = "Match already finished" });

        match.Team1Score = dto.Score1;
        match.Team2Score = dto.Score2;
        match.Status = "Finished";
        match.EndTime = DateTime.UtcNow;

        if (match.StartTime == null)
            match.StartTime = DateTime.UtcNow.AddMinutes(-60);

        // Determine winner
        if (dto.Score1 > dto.Score2)
        {
            match.WinnerTeam = 1;
        }
        else if (dto.Score2 > dto.Score1)
        {
            match.WinnerTeam = 2;
        }

        // If tournament is knockout, create next round match
        if (match.Tournament?.Format == "Singles" || match.Tournament?.Format == "Doubles")
        {
            var nextRoundMatches = await _context.Matches
                .Where(m => m.TournamentId == match.TournamentId && m.Round == match.Round + 1)
                .ToListAsync();

            // Logic to advance winner to next round would go here
            // For simplicity, we'll skip the bracket advancement logic
        }

        await _context.SaveChangesAsync();

        return Ok(new { message = "Match result updated successfully", match });
    }

    [HttpPatch("{id}/status")]
    [Authorize(Roles = "Admin")]
    public async Task<IActionResult> UpdateStatus(int id, [FromBody] UpdateMatchStatusDto dto)
    {
        var match = await _context.Matches.FindAsync(id);
        if (match == null)
            return NotFound();

        match.Status = dto.Status;

        if (dto.Status == "InProgress" && match.StartTime == null)
            match.StartTime = DateTime.UtcNow;

        await _context.SaveChangesAsync();
        return NoContent();
    }
}
