using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using SmartParking.Domain.Common;
using SmartParking.Domain.Entities;
using SmartParking.Infrastructure.Data;

namespace SmartParking.Features.Vehicles;

[ApiController]
[Authorize]
public class VehiclesController : ControllerBase
{
    private readonly AppDbContext _context;
    private readonly ICurrentUserService _currentUser;

    public VehiclesController(AppDbContext context, ICurrentUserService currentUser)
    {
        _context = context;
        _currentUser = currentUser;
    }

    [HttpGet("vehicles")]
    public async Task<ActionResult<IEnumerable<VehicleDto>>> GetVehicles()
    {
        var userId = _currentUser.UserId;
        if (userId is null)
            return Unauthorized();

        IQueryable<Vehicle> query = _context.Vehicles;

        if (!User.IsInRole("Admin"))
            query = query.Where(v => v.UserID == userId.Value);

        var vehicles = await query
            .OrderBy(v => v.VehicleID)
            .Select(v => new VehicleDto(v.VehicleID, v.LicensePlate, v.UserID))
            .ToListAsync();

        return Ok(vehicles);
    }

    [HttpPost("vehicles")]
    public async Task<ActionResult<VehicleDto>> RegisterVehicle(
        [FromBody] VehicleRegistrationRequestDto request
    )
    {
        var userId = _currentUser.UserId;
        if (userId is null)
            return Unauthorized();

        if (string.IsNullOrWhiteSpace(request.LicensePlate))
            return BadRequest(new { message = "licensePlate is required." });

        var licensePlate = request.LicensePlate.Trim();

        if (await _context.Vehicles.AnyAsync(v => v.LicensePlate == licensePlate))
            return BadRequest(new { message = "A vehicle with this license plate already exists." });

        var vehicle = new Vehicle { LicensePlate = licensePlate, UserID = userId.Value };

        _context.Vehicles.Add(vehicle);
        await _context.SaveChangesAsync();

        var dto = new VehicleDto(vehicle.VehicleID, vehicle.LicensePlate, vehicle.UserID);
        return CreatedAtAction(nameof(GetVehicles), new { vehicleId = vehicle.VehicleID }, dto);
    }

    [HttpDelete("vehicles/{vehicleId}")]
    public async Task<IActionResult> DeleteVehicle(int vehicleId)
    {
        var userId = _currentUser.UserId;
        if (userId is null)
            return Unauthorized();

        var vehicle = await _context.Vehicles.FindAsync(vehicleId);
        if (vehicle is null)
            return NotFound();

        if (!User.IsInRole("Admin") && vehicle.UserID != userId.Value)
            return Forbid();

        var inUse = await _context.Bookings.AnyAsync(b => b.VehicleID == vehicleId)
            || await _context.ParkingSessions.AnyAsync(s => s.VehicleID == vehicleId);

        if (inUse)
        {
            return BadRequest(
                new { message = "Cannot delete a vehicle that has bookings or parking sessions." }
            );
        }

        _context.Vehicles.Remove(vehicle);
        await _context.SaveChangesAsync();

        return NoContent();
    }
}
