namespace SmartParking.Features.Admin.DTOs;

public record ViolationDto(
    int ViolationID,
    string Type,
    DateTime DetectedAt,
    string Status,
    int UserID,
    int? SessionID
);
