using Microsoft.EntityFrameworkCore;
using PickleballAPI.Data;

namespace PickleballAPI.Services;

public class BookingCleanupService : BackgroundService
{
    private readonly IServiceProvider _serviceProvider;
    private readonly ILogger<BookingCleanupService> _logger;

    public BookingCleanupService(
        IServiceProvider serviceProvider,
        ILogger<BookingCleanupService> logger)
    {
        _serviceProvider = serviceProvider;
        _logger = logger;
    }

    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        _logger.LogInformation("Booking Cleanup Service is starting.");

        while (!stoppingToken.IsCancellationRequested)
        {
            await DoWork(stoppingToken);
            await Task.Delay(TimeSpan.FromMinutes(5), stoppingToken); // Run every 5 minutes
        }
    }

    private async Task DoWork(CancellationToken stoppingToken)
    {
        try
        {
            using var scope = _serviceProvider.CreateScope();
            var context = scope.ServiceProvider.GetRequiredService<ApplicationDbContext>();

            // Auto-cancel pending bookings older than 5 minutes
            var fiveMinutesAgo = DateTime.UtcNow.AddMinutes(-5);
            var pendingBookings = await context.Bookings
                .Where(b => b.Status == "Pending" && b.CreatedAt < fiveMinutesAgo)
                .ToListAsync(stoppingToken);

            foreach (var booking in pendingBookings)
            {
                booking.Status = "Cancelled";
                _logger.LogInformation($"Auto-cancelled booking {booking.Id} due to timeout");
            }

            if (pendingBookings.Any())
            {
                await context.SaveChangesAsync(stoppingToken);
                _logger.LogInformation($"Auto-cancelled {pendingBookings.Count} bookings");
            }

            // Auto-remind for bookings tomorrow
            var tomorrow = DateTime.Today.AddDays(1);
            var upcomingBookings = await context.Bookings
                .Include(b => b.Member)
                .Where(b => b.BookingDate == tomorrow && b.Status == "Confirmed")
                .ToListAsync(stoppingToken);

            // Here you could send notifications via SignalR or email
            foreach (var booking in upcomingBookings)
            {
                _logger.LogInformation($"Reminder: Booking {booking.Id} for {booking.Member?.FullName} tomorrow");
                // TODO: Send actual notification via SignalR Hub
            }
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error occurred executing booking cleanup service.");
        }
    }
}
