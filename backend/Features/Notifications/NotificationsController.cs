using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using SmartParking.Domain.Common;
using SmartParking.Infrastructure.Data;

namespace SmartParking.Features.Notifications;

[ApiController]
[Authorize]
public class NotificationsController : ControllerBase
{
    private readonly AppDbContext _context;
    private readonly ICurrentUserService _currentUser;

    public NotificationsController(AppDbContext context, ICurrentUserService currentUser)
    {
        _context = context;
        _currentUser = currentUser;
    }

    [HttpGet("notifications")]
    public async Task<ActionResult<IEnumerable<NotificationDto>>> GetNotifications()
    {
        var userId = _currentUser.UserId;
        if (userId is null)
            return Unauthorized();

        IQueryable<Domain.Entities.Notification> query = _context.Notifications.AsNoTracking();

        if (!User.IsInRole("Admin"))
            query = query.Where(n => n.UserID == userId.Value);

        var notifications = await query
            .OrderByDescending(n => n.SentAt)
            .Take(200)
            .Select(n => new NotificationDto(
                n.NotificationID,
                n.Type,
                n.Message,
                n.SentAt,
                n.Channel
            ))
            .ToListAsync();

        return Ok(notifications);
    }
}
