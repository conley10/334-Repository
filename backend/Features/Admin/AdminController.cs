using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using SmartParking.Domain.Entities;
using SmartParking.Domain.Enums;
using SmartParking.Features.Admin.DTOs;
using SmartParking.Features.Zones; // for ZoneDto
using System.Text.Json;

namespace SmartParking.Features.Admin;

[ApiController]
[Authorize(Roles = "Admin")]
public class AdminController : ControllerBase
{
    private readonly AdminService _adminService;
    private readonly Violations.ViolationService _violationService;

    public AdminController(AdminService adminService, Violations.ViolationService violationService)
    {
        _adminService = adminService;
        _violationService = violationService;
    }

    // ---------------- USERS ----------------

    [HttpGet("admin/users")]
    public async Task<ActionResult<IEnumerable<UserDto>>> ListUsers()
    {
        var users = await _adminService.GetAllUsersAsync();

        var dtos = users.Select(u => new UserDto(
            u.UserID,
            u.Name,
            u.Email,
            u.Role.ToString().ToLower()
        ));

        return Ok(dtos);
    }

    [HttpPatch("admin/users/{userId}/role")]
    public async Task<ActionResult<IEnumerable<UserDto>>> UpdateUserRole(int userId, [FromBody] UpdateRoleRequest request)
    {
        var user = await _adminService.GetUserByIdAsync(userId);
        if (user == null)
            return NotFound(new { message = "User not found" });

        if (!Enum.TryParse<UserRole>(request.Role, true, out var parsedRole))
            return BadRequest(new { message = "Invalid role" });

        user.Role = parsedRole;
        await _adminService.UpdateUserAsync(user);

        return Ok(new UserDto(
            user.UserID,
            user.Name,
            user.Email,
            user.Role.ToString().ToLower()
        ));
    }

    // ---------------- ZONES ----------------

    [HttpGet("admin/zones")]
    public async Task<ActionResult<IEnumerable<ZoneDto>>> GetZones()
    {
        var zones = await _adminService.GetAllZonesAsync();

        var dtos = zones.Select(z => new ZoneDto(
            z.ZoneID,
            z.Name,
            z.Capacity,
            z.PricePerHour,
            z.MaxDuration,
            z.AccessLevel.ToString().ToLower(),
            z.ZoneType.ToString().ToLower(),
            JsonSerializer.Deserialize<object>(z.GeoJson) ?? new { }
        ));

        return Ok(dtos);
    }

    [HttpPost("admin/zones")]
    public async Task<ActionResult> CreateZone([FromBody] CreateZoneRequest request)
    {
        if (!Enum.TryParse<ZoneType>(request.ZoneType, true, out var zoneType))
            return BadRequest(new { message = "Invalid zone type" });

        if (!Enum.TryParse<AccessLevel>(request.AccessLevel, true, out var accessLevel))
            return BadRequest(new { message = "Invalid access level" });

        var zone = new Zone
        {
            Name = request.Name,
            Capacity = request.Capacity,
            PricePerHour = request.PricePerHour,
            MaxDuration = request.MaxDuration,
            GeoJson = request.GeoJson,
            ZoneType = zoneType,
            AccessLevel = accessLevel
        };

        var created = await _adminService.CreateZoneAsync(zone);

        return Ok(new ZoneDto(
            created.ZoneID,
            created.Name,
            created.Capacity,
            created.PricePerHour,
            created.MaxDuration,
            created.AccessLevel.ToString().ToLower(),
            created.ZoneType.ToString().ToLower(),
            JsonSerializer.Deserialize<object>(created.GeoJson) ?? new { }
        ));
    }

    [HttpPatch("admin/zones/{zoneId}")]
    public async Task<ActionResult> UpdateZone(int zoneId, [FromBody] UpdateZoneRequest request)
    {
        var zone = await _adminService.GetZoneAsync(zoneId);
        if (zone == null)
            return NotFound(new { message = "Zone not found" });

        zone.Name = request.Name ?? zone.Name;
        zone.GeoJson = request.GeoJson ?? zone.GeoJson;

        if (request.Capacity.HasValue)
            zone.Capacity = request.Capacity.Value;

        if (request.PricePerHour.HasValue)
            zone.PricePerHour = request.PricePerHour.Value;

        if (request.MaxDuration.HasValue)
            zone.MaxDuration = request.MaxDuration.Value;

        if (request.ZoneType != null &&
            Enum.TryParse<ZoneType>(request.ZoneType, true, out var parsedZoneType))
            zone.ZoneType = parsedZoneType;

        if (request.AccessLevel != null &&
            Enum.TryParse<AccessLevel>(request.AccessLevel, true, out var parsedAccess))
            zone.AccessLevel = parsedAccess;

        await _adminService.UpdateZoneAsync(zone);

        return Ok(new ZoneDto(
            zone.ZoneID,
            zone.Name,
            zone.Capacity,
            zone.PricePerHour,
            zone.MaxDuration,
            zone.AccessLevel.ToString().ToLower(),
            zone.ZoneType.ToString().ToLower(),
            JsonSerializer.Deserialize<object>(zone.GeoJson) ?? new { }
        ));
    }

    [HttpDelete("admin/zones/{zoneId}")]
    public async Task<ActionResult> DeleteZone(int zoneId)
    {
        var zone = await _adminService.GetZoneAsync(zoneId);
        if (zone == null)
            return NotFound(new { message = "Zone not found" });

        await _adminService.DeleteZoneAsync(zone);

        return Ok(new { message = "Zone deleted" });
    }

    // ---------------- SPOT OVERRIDE ----------------

    [HttpPatch("admin/zones/{zoneId}/spots/{spotId}/status")]
    public async Task<ActionResult> OverrideSpotStatus(int zoneId, int spotId, [FromBody] OverrideSpotStatusRequest request)
    {
        if (!Enum.TryParse<SpotStatus>(request.Status, true, out var parsedStatus))
            return BadRequest(new { message = "Invalid spot status" });

        var success = await _adminService.OverrideSpotStatusAsync(zoneId, spotId, parsedStatus);

        if (!success)
            return NotFound(new { message = "Spot not found" });

        return Ok(new { message = "Spot status updated" });
    }

    // ---------------- VIOLATIONS ----------------

    [HttpGet("admin/violations")]
    public async Task<ActionResult<IEnumerable<ViolationDto>>> GetViolations()
    {
        var violations = await _violationService.GetAllViolationsAsync();

        var dtos = violations.Select(v => new ViolationDto(
            v.ViolationID,
            v.Type.ToString().ToLower(),
            v.DetectedAt,
            v.Status.ToString().ToLower(),
            v.UserID,
            v.SessionID
        ));

        return Ok(dtos);
    }

    // ---------------- REPORTS ----------------

    [HttpGet("admin/reports")]
    public async Task<ActionResult<ReportDto>> GetReports()
    {
        var report = await _adminService.GenerateReportAsync();
        return Ok(report);
    }

}

// ---------------- REQUEST MODELS ----------------

public class UpdateRoleRequest
{
    public string Role { get; set; } = "";
}

public class CreateZoneRequest
{
    public string Name { get; set; } = "";
    public int Capacity { get; set; }
    public double PricePerHour { get; set; }
    public int MaxDuration { get; set; }
    public string AccessLevel { get; set; } = "";
    public string ZoneType { get; set; } = "";
    public string GeoJson { get; set; } = "";
}

public class UpdateZoneRequest
{
    public string? Name { get; set; }
    public int? Capacity { get; set; }
    public double? PricePerHour { get; set; }
    public int? MaxDuration { get; set; }
    public string? AccessLevel { get; set; }
    public string? ZoneType { get; set; }
    public string? GeoJson { get; set; }
}

public class OverrideSpotStatusRequest
{
    public string Status { get; set; } = "";
}
