namespace SmartParking.Features.Vehicles;

public record VehicleDto(int VehicleID, string LicensePlate, int UserID);

public record VehicleRegistrationRequestDto(string? LicensePlate);
