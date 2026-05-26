namespace SmartParking.Features.Admin.DTOs;

public record UserDto(
    int UserID,
    string Name,
    string Email,
    string Role,
    string Status,
    DateTime JoinedAt,
    int TotalBookings
);
