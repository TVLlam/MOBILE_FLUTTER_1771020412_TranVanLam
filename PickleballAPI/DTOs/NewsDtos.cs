namespace PickleballAPI.DTOs;

public class NewsDto
{
    public int Id { get; set; }
    public string Title { get; set; } = string.Empty;
    public string Content { get; set; } = string.Empty;
    public string? ImageUrl { get; set; }
    public bool IsPinned { get; set; }
    public DateTime CreatedAt { get; set; }
}

public class CreateNewsDto
{
    public string Title { get; set; } = string.Empty;
    public string Content { get; set; } = string.Empty;
    public string? ImageUrl { get; set; }
    public bool? IsPinned { get; set; }
}

public class UpdateNewsDto
{
    public string? Title { get; set; }
    public string? Content { get; set; }
    public string? ImageUrl { get; set; }
    public bool? IsPinned { get; set; }
}
