using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using PickleballAPI.Data;
using PickleballAPI.DTOs;
using PickleballAPI.Models;

namespace PickleballAPI.Controllers;

[ApiController]
[Route("api/[controller]")]
public class NewsController : ControllerBase
{
    private readonly ApplicationDbContext _context;
    
    public NewsController(ApplicationDbContext context)
    {
        _context = context;
    }
    
    [HttpGet]
    [AllowAnonymous]
    public async Task<ActionResult<IEnumerable<NewsDto>>> GetNews()
    {
        var news = await _context.News
            .OrderByDescending(n => n.IsPinned)
            .ThenByDescending(n => n.CreatedAt)
            .Select(n => new NewsDto
            {
                Id = n.Id,
                Title = n.Title,
                Content = n.Content,
                ImageUrl = n.ImageUrl,
                IsPinned = n.IsPinned,
                CreatedAt = n.CreatedAt
            })
            .ToListAsync();
        
        return Ok(news);
    }
    
    [HttpGet("{id}")]
    [AllowAnonymous]
    public async Task<ActionResult<NewsDto>> GetNewsById(int id)
    {
        var news = await _context.News.FindAsync(id);
        if (news == null)
            return NotFound();
        
        return Ok(new NewsDto
        {
            Id = news.Id,
            Title = news.Title,
            Content = news.Content,
            ImageUrl = news.ImageUrl,
            IsPinned = news.IsPinned,
            CreatedAt = news.CreatedAt
        });
    }
    
    [HttpPost]
    [Authorize(Roles = "Admin")]
    public async Task<ActionResult<NewsDto>> CreateNews([FromBody] CreateNewsDto dto)
    {
        var news = new News
        {
            Title = dto.Title,
            Content = dto.Content,
            ImageUrl = dto.ImageUrl,
            IsPinned = dto.IsPinned ?? false,
            CreatedAt = DateTime.UtcNow
        };
        
        _context.News.Add(news);
        await _context.SaveChangesAsync();
        
        return CreatedAtAction(nameof(GetNewsById), new { id = news.Id }, new NewsDto
        {
            Id = news.Id,
            Title = news.Title,
            Content = news.Content,
            ImageUrl = news.ImageUrl,
            IsPinned = news.IsPinned,
            CreatedAt = news.CreatedAt
        });
    }
    
    [HttpPut("{id}")]
    [Authorize(Roles = "Admin")]
    public async Task<IActionResult> UpdateNews(int id, [FromBody] UpdateNewsDto dto)
    {
        var news = await _context.News.FindAsync(id);
        if (news == null)
            return NotFound();
        
        if (!string.IsNullOrEmpty(dto.Title))
            news.Title = dto.Title;
        if (!string.IsNullOrEmpty(dto.Content))
            news.Content = dto.Content;
        if (!string.IsNullOrEmpty(dto.ImageUrl))
            news.ImageUrl = dto.ImageUrl;
        if (dto.IsPinned.HasValue)
            news.IsPinned = dto.IsPinned.Value;
        
        await _context.SaveChangesAsync();
        
        return NoContent();
    }
    
    [HttpDelete("{id}")]
    [Authorize(Roles = "Admin")]
    public async Task<IActionResult> DeleteNews(int id)
    {
        var news = await _context.News.FindAsync(id);
        if (news == null)
            return NotFound();
        
        _context.News.Remove(news);
        await _context.SaveChangesAsync();
        
        return NoContent();
    }
}
