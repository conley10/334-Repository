namespace SmartParking.Features.Admin.DTOs;

public record ReportDto(
    int TotalUsers,
    int TotalZones,
    int TotalSpots,
    int TotalViolations
);
