using Microsoft.AspNetCore.SignalR;

namespace PickleballAPI.Hubs;

public class PcmHub : Hub
{
    public async Task SendNotification(string userId, string message, string type = "info")
    {
        await Clients.User(userId).SendAsync("ReceiveNotification", new
        {
            message,
            type,
            timestamp = DateTime.UtcNow
        });
    }

    public async Task BroadcastNotification(string message, string type = "info")
    {
        await Clients.All.SendAsync("ReceiveNotification", new
        {
            message,
            type,
            timestamp = DateTime.UtcNow
        });
    }

    public async Task UpdateCalendar(string userId)
    {
        await Clients.User(userId).SendAsync("UpdateCalendar", new
        {
            timestamp = DateTime.UtcNow
        });
    }

    public async Task BroadcastCalendarUpdate()
    {
        await Clients.All.SendAsync("UpdateCalendar", new
        {
            timestamp = DateTime.UtcNow
        });
    }

    public async Task UpdateMatchScore(int matchId, int score1, int score2)
    {
        await Clients.Group($"match_{matchId}").SendAsync("UpdateMatchScore", new
        {
            matchId,
            score1,
            score2,
            timestamp = DateTime.UtcNow
        });
    }

    public async Task JoinMatchGroup(int matchId)
    {
        await Groups.AddToGroupAsync(Context.ConnectionId, $"match_{matchId}");
    }

    public async Task LeaveMatchGroup(int matchId)
    {
        await Groups.RemoveFromGroupAsync(Context.ConnectionId, $"match_{matchId}");
    }

    public override async Task OnConnectedAsync()
    {
        var userId = Context.UserIdentifier;
        if (!string.IsNullOrEmpty(userId))
        {
            await Groups.AddToGroupAsync(Context.ConnectionId, $"user_{userId}");
        }
        await base.OnConnectedAsync();
    }

    public override async Task OnDisconnectedAsync(Exception? exception)
    {
        var userId = Context.UserIdentifier;
        if (!string.IsNullOrEmpty(userId))
        {
            await Groups.RemoveFromGroupAsync(Context.ConnectionId, $"user_{userId}");
        }
        await base.OnDisconnectedAsync(exception);
    }
}
