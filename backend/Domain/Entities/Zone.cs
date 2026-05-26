using SmartParking.Domain.Enums;

namespace SmartParking.Domain.Entities;

public class Zone
{
    public int ZoneID { get; set; }
    public string Name { get; set; } = string.Empty;
    public int Capacity { get; set; }
    public double PricePerHour { get; set; }
    public int MaxDuration { get; set; }
    public AccessLevel AccessLevel { get; set; }
    public ZoneType ZoneType { get; set; }
    public ZoneStatus Status { get; set; } = ZoneStatus.Active;
    public string GeoJson { get; set; } = string.Empty;

    public ICollection<ParkingSpot> Spots { get; set; } = new List<ParkingSpot>();
}
