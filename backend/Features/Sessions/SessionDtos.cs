namespace SmartParking.Features.Sessions;

public record ParkingSessionDto(
    int SessionID,
    DateTime StartTime,
    DateTime? EndTime,
    string Status,
    int UserID,
    int SpotID,
    int VehicleID
);
