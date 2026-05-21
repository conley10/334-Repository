using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using SmartParking.Domain.Common;
using SmartParking.Domain.Entities;
using SmartParking.Domain.Enums;
using SmartParking.Infrastructure.Data;

namespace SmartParking.Features.Bookings;

[ApiController]
[Authorize]
public class BookingsController : ControllerBase
{
    private readonly AppDbContext _context;
    private readonly ICurrentUserService _currentUser;

    public BookingsController(AppDbContext context, ICurrentUserService currentUser)
    {
        _context = context;
        _currentUser = currentUser;
    }

    [HttpGet("bookings")]
    public async Task<ActionResult<IEnumerable<BookingDto>>> GetBookings(
        [FromQuery] string? status
    )
    {
        var userId = _currentUser.UserId;
        if (userId is null)
            return Unauthorized();

        IQueryable<Booking> query = _context.Bookings;

        if (!User.IsInRole("Admin"))
            query = query.Where(b => b.UserID == userId.Value);

        if (!string.IsNullOrWhiteSpace(status))
        {
            if (!TryParseStatusFilter(status, out var filter))
                return BadRequest(new { message = "status must be upcoming, past, or cancelled." });

            var now = DateTime.UtcNow;
            query = filter switch
            {
                BookingStatus.Upcoming => query.Where(b =>
                    b.Status == BookingStatus.Upcoming && b.EndTime > now
                ),
                BookingStatus.Past => query.Where(b =>
                    b.Status == BookingStatus.Past || b.EndTime <= now
                ),
                BookingStatus.Cancelled => query.Where(b => b.Status == BookingStatus.Cancelled),
                _ => query,
            };
        }

        var bookings = await query.OrderBy(b => b.StartTime).ToListAsync();

        return Ok(bookings.Select(ToDto));
    }

    [HttpPost("bookings")]
    public async Task<ActionResult<BookingDto>> CreateBooking([FromBody] BookingRequestDto request)
    {
        var userId = _currentUser.UserId;
        if (userId is null)
            return Unauthorized();

        var targetUserId = User.IsInRole("Admin") && request.UserID.HasValue
            ? request.UserID.Value
            : userId.Value;

        var validation = await ValidateBookingRequestAsync(request, targetUserId, excludeBookingId: null);
        if (validation.Error is not null)
            return validation.Error;

        var booking = new Booking
        {
            StartTime = request.StartTime.ToUniversalTime(),
            EndTime = request.EndTime.ToUniversalTime(),
            Status = BookingStatus.Upcoming,
            UserID = targetUserId,
            SpotID = request.SpotID,
            VehicleID = request.VehicleID,
        };

        _context.Bookings.Add(booking);
        await _context.SaveChangesAsync();

        return CreatedAtAction(
            nameof(GetBooking),
            new { bookingId = booking.BookingID },
            ToDto(booking)
        );
    }

    [HttpGet("bookings/{bookingId}")]
    public async Task<ActionResult<BookingDto>> GetBooking(int bookingId)
    {
        var booking = await FindBookingAsync(bookingId);
        if (booking is null)
            return NotFound();

        return Ok(ToDto(booking));
    }

    [HttpPatch("bookings/{bookingId}")]
    public async Task<ActionResult<BookingDto>> UpdateBooking(
        int bookingId,
        [FromBody] BookingRequestDto request
    )
    {
        var booking = await FindBookingAsync(bookingId);
        if (booking is null)
            return NotFound();

        if (booking.Status == BookingStatus.Cancelled)
            return BadRequest(new { message = "Cannot modify a cancelled booking." });

        var targetUserId = booking.UserID;
        var validation = await ValidateBookingRequestAsync(request, targetUserId, bookingId);
        if (validation.Error is not null)
            return validation.Error;

        booking.StartTime = request.StartTime.ToUniversalTime();
        booking.EndTime = request.EndTime.ToUniversalTime();
        booking.SpotID = request.SpotID;
        booking.VehicleID = request.VehicleID;

        await _context.SaveChangesAsync();

        return Ok(ToDto(booking));
    }

    [HttpDelete("bookings/{bookingId}")]
    public async Task<IActionResult> CancelBooking(int bookingId)
    {
        var booking = await FindBookingAsync(bookingId);
        if (booking is null)
            return NotFound();

        if (booking.Status == BookingStatus.Cancelled)
            return NoContent();

        booking.Status = BookingStatus.Cancelled;
        await _context.SaveChangesAsync();

        return NoContent();
    }

    private async Task<Booking?> FindBookingAsync(int bookingId)
    {
        var userId = _currentUser.UserId;
        if (userId is null)
            return null;

        var query = _context.Bookings.AsQueryable();
        if (!User.IsInRole("Admin"))
            query = query.Where(b => b.UserID == userId.Value);

        return await query.FirstOrDefaultAsync(b => b.BookingID == bookingId);
    }

    private async Task<(ActionResult? Error, ParkingSpot? Spot)> ValidateBookingRequestAsync(
        BookingRequestDto request,
        int userId,
        int? excludeBookingId
    )
    {
        if (request.EndTime <= request.StartTime)
        {
            return (
                BadRequest(new { message = "endTime must be after startTime." }),
                null
            );
        }

        var spot = await _context
            .ParkingSpots.Include(s => s.Zone)
            .FirstOrDefaultAsync(s => s.SpotID == request.SpotID);

        if (spot is null)
            return (BadRequest(new { message = "spotID does not exist." }), null);

        var durationHours = (request.EndTime - request.StartTime).TotalHours;
        if (durationHours > spot.Zone.MaxDuration)
        {
            return (
                BadRequest(
                    new
                    {
                        message = $"Booking exceeds zone max duration of {spot.Zone.MaxDuration} hours.",
                    }
                ),
                null
            );
        }

        var vehicle = await _context.Vehicles.FirstOrDefaultAsync(v =>
            v.VehicleID == request.VehicleID && v.UserID == userId
        );

        if (vehicle is null)
            return (BadRequest(new { message = "vehicleID is invalid for this user." }), null);

        var start = request.StartTime.ToUniversalTime();
        var end = request.EndTime.ToUniversalTime();

        var conflict = await _context.Bookings.AnyAsync(b =>
            b.BookingID != excludeBookingId
            && b.SpotID == request.SpotID
            && b.Status != BookingStatus.Cancelled
            && b.StartTime < end
            && b.EndTime > start
        );

        if (conflict)
        {
            return (
                Conflict(
                    new
                    {
                        error = "Conflict",
                        message = "The spot is already booked for the requested time slot.",
                    }
                ),
                null
            );
        }

        return (null, spot);
    }

    private static bool TryParseStatusFilter(string status, out BookingStatus filter)
    {
        switch (status.Trim().ToLowerInvariant())
        {
            case "upcoming":
                filter = BookingStatus.Upcoming;
                return true;
            case "past":
                filter = BookingStatus.Past;
                return true;
            case "cancelled":
                filter = BookingStatus.Cancelled;
                return true;
            default:
                filter = default;
                return false;
        }
    }

    private static BookingDto ToDto(Booking booking) =>
        new(
            booking.BookingID,
            booking.StartTime,
            booking.EndTime,
            booking.UserID,
            booking.SpotID,
            booking.VehicleID,
            booking.Status.ToString().ToLowerInvariant()
        );
}
