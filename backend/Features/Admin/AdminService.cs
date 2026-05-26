using Microsoft.EntityFrameworkCore;
using SmartParking.Domain.Entities;
using SmartParking.Domain.Enums;
using SmartParking.Infrastructure.Data;
using SmartParking.Features.Admin.DTOs;


namespace SmartParking.Features.Admin;

public class AdminService
{
    private readonly AppDbContext _db;

    public AdminService(AppDbContext db)
    {
        _db = db;
    }

    // ---------------- USERS ----------------

    public async Task<List<User>> GetAllUsersAsync()
    {
        return await _db.Users
            .Include(u => u.Bookings)
            .AsNoTracking()
            .ToListAsync();
    }

    public async Task<User?> GetUserByIdAsync(int id)
    {
        return await _db.Users
            .Include(u => u.Bookings)
            .FirstOrDefaultAsync(u => u.UserID == id);
    }

    public async Task UpdateUserAsync(User user)
    {
        _db.Users.Update(user);
        await _db.SaveChangesAsync();
    }

    // ---------------- ZONES ----------------

    public async Task<List<Zone>> GetAllZonesAsync()
    {
        return await _db.Zones
            .Include(z => z.Spots)
            .AsNoTracking()
            .ToListAsync();
    }

    public async Task<Zone> CreateZoneAsync(Zone zone)
    {
        _db.Zones.Add(zone);
        await _db.SaveChangesAsync();
        return zone;
    }

    public async Task<Zone?> GetZoneAsync(int id)
    {
        return await _db.Zones
            .Include(z => z.Spots)
            .FirstOrDefaultAsync(z => z.ZoneID == id);
    }

    public async Task UpdateZoneAsync(Zone zone)
    {
        _db.Zones.Update(zone);
        await _db.SaveChangesAsync();
    }

    public async Task DeleteZoneAsync(Zone zone)
    {
        _db.Zones.Remove(zone);
        await _db.SaveChangesAsync();
    }


    // ---------------- SPOT OVERRIDE ----------------

    public async Task<bool> OverrideSpotStatusAsync(int zoneId, int spotId, SpotStatus newStatus)
    {
        var spot = await _db.ParkingSpots
            .FirstOrDefaultAsync(s => s.SpotID == spotId && s.ZoneID == zoneId);

        if (spot == null)
            return false;

        spot.Status = newStatus;
        await _db.SaveChangesAsync();
        return true;
    }

    // ---------------- REPORTS ----------------

    public async Task<ReportDto> GenerateReportAsync()
    {
        return new ReportDto(
            TotalUsers: await _db.Users.CountAsync(),
            TotalZones: await _db.Zones.CountAsync(),
            TotalSpots: await _db.ParkingSpots.CountAsync(),
            TotalViolations: await _db.Violations.CountAsync()
        );
    }

}
