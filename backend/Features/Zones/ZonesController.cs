using System.ComponentModel.DataAnnotations;
using System.Text.Json;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using SmartParking.Domain.Enums;
using SmartParking.Infrastructure.Data;

namespace SmartParking.Features.Zones;

[ApiController]
[Authorize]
public class ZonesController : ControllerBase
{
    private readonly AppDbContext _context;
    private readonly IZoneService _zoneService;

    public ZonesController(AppDbContext context, IZoneService zoneService)
    {
        _context = context;
        _zoneService = zoneService;
    }

    [HttpGet("zones")]
    public async Task<ActionResult<IEnumerable<ZoneDto>>> GetZones()
    {
        var zones = await _context
            .Zones.Select(z => new ZoneDto(
                z.ZoneID,
                z.Name,
                z.Capacity,
                z.PricePerHour,
                z.MaxDuration,
                z.AccessLevel.ToString().ToLower(),
                z.ZoneType.ToString().ToLower(),
                z.Status.ToString().ToLower(),
                z.Spots.Count(s => s.Status == SpotStatus.Available),
                JsonSerializer.Deserialize<object>(z.GeoJson, (JsonSerializerOptions?)null)
                    ?? new { }
            ))
            .ToListAsync();

        return Ok(zones);
    }

    [HttpGet("zones/{zoneId}/spots")]
    public async Task<ActionResult<IEnumerable<ParkingSpotDto>>> GetSpots(int zoneId)
    {
        var zoneExists = await _context.Zones.AnyAsync(z => z.ZoneID == zoneId);
        if (!zoneExists)
            return NotFound();

        var spots = await _context
            .ParkingSpots.Where(s => s.ZoneID == zoneId)
            .Select(s => new ParkingSpotDto(
                s.SpotID,
                s.SpotNumber,
                s.Status.ToString().ToLower(),
                s.ZoneID
            ))
            .ToListAsync();

        return Ok(spots);
    }

    [HttpGet("zones/{zoneId}/stats")]
    public async Task<ActionResult<ZoneStatsDto>> GetStats(int zoneId)
    {
        try
        {
            var stats = await _zoneService.GetZoneStatsAsync(zoneId);
            return Ok(stats);
        }
        catch (KeyNotFoundException)
        {
            return NotFound();
        }
    }

    [HttpGet("zones/{zoneId}/predictions")]
    public async Task<ActionResult<PredictionResponseDto>> GetPredictions(
        int zoneId,
        [FromQuery, Required] DateTime startDateTime,
        [FromQuery, Required] DateTime endDateTime
    )
    {
        try
        {
            var predictions = await _zoneService.GetPredictionsAsync(zoneId, startDateTime, endDateTime);
            return Ok(predictions);
        }
        catch (KeyNotFoundException)
        {
            return NotFound();
        }
    }

    [HttpGet("zones/recommendations")]
    public async Task<ActionResult<IEnumerable<ZoneDto>>> GetRecommendations(
        double originLat,
        double originLng
    )
    {
        var recommendedZones = await _zoneService.GetRecommendedZonesAsync(originLat, originLng);

        var result = recommendedZones.Select(z => new ZoneDto(
            z.ZoneID,
            z.Name,
            z.Capacity,
            z.PricePerHour,
            z.MaxDuration,
            z.AccessLevel.ToString().ToLower(),
            z.ZoneType.ToString().ToLower(),
            z.Status.ToString().ToLower(),
            z.Spots.Count(s => s.Status == SpotStatus.Available),
            JsonSerializer.Deserialize<object>(z.GeoJson, (JsonSerializerOptions?)null) ?? new { }
        ));

        return Ok(result);
    }
}
