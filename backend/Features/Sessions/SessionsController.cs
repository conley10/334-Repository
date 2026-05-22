using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using SmartParking.Domain.Common;
using SmartParking.Domain.Entities;
using SmartParking.Infrastructure.Data;

namespace SmartParking.Features.Sessions;

[ApiController]
[Authorize]
public class SessionsController : ControllerBase
{
    private readonly AppDbContext _context;
    private readonly ICurrentUserService _currentUser;

    public SessionsController(AppDbContext context, ICurrentUserService currentUser)
    {
        _context = context;
        _currentUser = currentUser;
    }

    [HttpGet("parking-sessions")]
    public async Task<ActionResult<IEnumerable<ParkingSessionDto>>> GetSessions(
        [FromQuery] bool? active
    )
    {
        var userId = _currentUser.UserId;
        if (userId is null)
            return Unauthorized();

        IQueryable<ParkingSession> query = _context.ParkingSessions.AsNoTracking();

        if (!User.IsInRole("Admin"))
            query = query.Where(s => s.UserID == userId.Value);

        if (active == true)
        {
            query = query.Where(s =>
                s.EndTime == null
                || EF.Functions.ILike(s.Status, "active")
                || EF.Functions.ILike(s.Status, "expiring")
            );
        }
        else if (active == false)
        {
            // Seed ghost history creates tens of thousands of "Completed" rows — filter + cap.
            query = query.Where(s =>
                s.EndTime != null
                || EF.Functions.ILike(s.Status, "completed")
            );
        }

        query = query.OrderByDescending(s => s.StartTime);

        // Unfiltered or completed-only lists can be huge; active=true stays small.
        if (active != true)
            query = query.Take(200);

        var sessions = await query.ToListAsync();

        return Ok(sessions.Select(ToDto));
    }

    private static ParkingSessionDto ToDto(ParkingSession session) =>
        new(
            session.SessionID,
            session.StartTime,
            session.EndTime,
            session.Status.ToLowerInvariant(),
            session.UserID,
            session.SpotID,
            session.VehicleID
        );
}
