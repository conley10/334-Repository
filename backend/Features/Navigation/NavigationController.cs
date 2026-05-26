using System.Net.Http;
using System.Text.Json;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using SmartParking.Infrastructure.Data;

namespace SmartParking.Features.Navigation;

[ApiController]
[Authorize]
public class NavigationController : ControllerBase
{
    private readonly AppDbContext _context;
    private readonly IHttpClientFactory _httpClientFactory;

    public NavigationController(AppDbContext context, IHttpClientFactory httpClientFactory)
    {
        _context = context;
        _httpClientFactory = httpClientFactory;
    }

    [HttpGet("navigation/route")]
    public async Task<ActionResult<RouteDto>> GetRoute(
        [FromQuery] double originLat,
        [FromQuery] double originLng,
        [FromQuery] int targetZoneID
    )
    {
        var zone = await _context.Zones.FirstOrDefaultAsync(z => z.ZoneID == targetZoneID);
        if (zone is null)
            return NotFound();

        var (destLat, destLng) = GetCentroid(zone.GeoJson);
        if (destLat == 0 && destLng == 0)
            return BadRequest(new { message = "Zone GeoJSON is invalid or missing coordinates." });

        // Try calling OpenStreetMap OSRM Routing API
        try
        {
            var client = _httpClientFactory.CreateClient();
            client.Timeout = TimeSpan.FromSeconds(5);
            client.DefaultRequestHeaders.UserAgent.ParseAdd("SmartParking/1.0");

            var url = $"http://router.project-osrm.org/route/v1/driving/{originLng:F6},{originLat:F6};{destLng:F6},{destLat:F6}?overview=full&geometries=geojson";
            var response = await client.GetAsync(url);
            if (response.IsSuccessStatusCode)
            {
                var content = await response.Content.ReadAsStringAsync();
                using var doc = JsonDocument.Parse(content);
                var root = doc.RootElement;
                if (root.TryGetProperty("code", out var codeProp) && codeProp.GetString() == "Ok")
                {
                    if (root.TryGetProperty("routes", out var routesProp) && routesProp.ValueKind == JsonValueKind.Array && routesProp.GetArrayLength() > 0)
                    {
                        var firstRoute = routesProp[0];
                        var distance = firstRoute.GetProperty("distance").GetDouble();
                        var duration = firstRoute.GetProperty("duration").GetDouble();
                        
                        if (firstRoute.TryGetProperty("geometry", out var geometry) && 
                            geometry.TryGetProperty("coordinates", out var coords) && 
                            coords.ValueKind == JsonValueKind.Array)
                        {
                            var points = new System.Collections.Generic.List<string>();
                            foreach (var coord in coords.EnumerateArray())
                            {
                                if (coord.GetArrayLength() == 2)
                                {
                                    var lng = coord[0].GetDouble();
                                    var lat = coord[1].GetDouble();
                                    points.Add($"{lat:F6},{lng:F6}");
                                }
                            }
                            
                            if (points.Count > 0)
                            {
                                var polylineStr = string.Join(";", points);
                                var distanceM = (int)Math.Round(distance);
                                var durationMins = Math.Max(1, (int)Math.Ceiling(duration / 60.0));
                                return Ok(new RouteDto(distanceM, durationMins, polylineStr));
                            }
                        }
                    }
                }
            }
        }
        catch
        {
            // Fall back gracefully to Haversine straight line route calculation below if external service fails/times out
        }

        var distanceKm = HaversineDistanceKm(originLat, originLng, destLat, destLng);
        var distanceMeters = (int)Math.Round(distanceKm * 1000);
        var estimatedMinutes = Math.Max(1, (int)Math.Ceiling(distanceKm / 40.0 * 60));

        var polyline =
            $"{originLat:F6},{originLng:F6};{destLat:F6},{destLng:F6}";

        return Ok(new RouteDto(distanceMeters, estimatedMinutes, polyline));
    }

    private static (double Lat, double Lng) GetCentroid(string geoJson)
    {
        try
        {
            using var doc = JsonDocument.Parse(geoJson);
            var root = doc.RootElement;
            var lats = new List<double>();
            var lngs = new List<double>();

            void ExtractCoords(JsonElement element)
            {
                if (element.ValueKind == JsonValueKind.Array)
                {
                    if (
                        element.GetArrayLength() == 2
                        && element[0].ValueKind == JsonValueKind.Number
                    )
                    {
                        lngs.Add(element[0].GetDouble());
                        lats.Add(element[1].GetDouble());
                    }
                    else
                    {
                        foreach (var item in element.EnumerateArray())
                            ExtractCoords(item);
                    }
                }
            }

            ExtractCoords(root.GetProperty("coordinates"));

            if (lats.Count == 0 || lngs.Count == 0)
                return (0, 0);

            return (lats.Average(), lngs.Average());
        }
        catch
        {
            return (0, 0);
        }
    }

    private static double HaversineDistanceKm(double lat1, double lon1, double lat2, double lon2)
    {
        const double R = 6371;
        var dLat = ToRadians(lat2 - lat1);
        var dLon = ToRadians(lon2 - lon1);

        var a =
            Math.Sin(dLat / 2) * Math.Sin(dLat / 2)
            + Math.Cos(ToRadians(lat1))
                * Math.Cos(ToRadians(lat2))
                * Math.Sin(dLon / 2)
                * Math.Sin(dLon / 2);

        var c = 2 * Math.Atan2(Math.Sqrt(a), Math.Sqrt(1 - a));
        return R * c;
    }

    private static double ToRadians(double angle) => Math.PI * angle / 180.0;
}
