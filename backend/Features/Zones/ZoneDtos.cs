namespace SmartParking.Features.Zones;

public record ZoneDto(
    int ZoneID,
    string Name,
    int Capacity,
    double PricePerHour,
    int MaxDuration,
    string AccessLevel,
    string ZoneType,
    string Status,
    int AvailableSpots,
    object GeoJson
);

public record ParkingSpotDto(
    int SpotID,
    string SpotNumber,
    string Status,
    int ZoneID
);

public record TrendItemDto(string Label, double Value);

public record ZoneStatsDto(
    int ZoneID,
    double AverageOccupancy,
    TrendItemDto[] WeeklyTrends,
    TrendItemDto[] HourlyTrends
);

public record PredictionItemDto(
    DateTime TimeSlot,
    double Probability,
    int EstimatedSpotsAvailable
);

public record PredictionResponseDto(
    int ZoneID,
    PredictionItemDto[] Predictions
);
