namespace SmartParking.Features.Bookings;

public record BookingDto(
    int BookingID,
    DateTime StartTime,
    DateTime EndTime,
    int UserID,
    int SpotID,
    int VehicleID,
    string Status
);

public record BookingRequestDto(
    DateTime StartTime,
    DateTime EndTime,
    int? UserID,
    int SpotID,
    int VehicleID
);
