using Microsoft.EntityFrameworkCore;
using SmartParking.Domain.Entities;
using SmartParking.Infrastructure.Data;

namespace SmartParking.Features.Violations;

public class ViolationService
{
    private readonly AppDbContext _db;

    public ViolationService(AppDbContext db)
    {
        _db = db;
    }

    public async Task<List<Violation>> GetAllViolationsAsync()
    {
        return await _db.Violations
            .AsNoTracking()
            .ToListAsync();
    }
}
