using SmartParking.Domain.Enums;

namespace SmartParking.Domain.Entities;

public class User
{
    public int UserID { get; set; }
    public string Name { get; set; } = string.Empty;
    public string Email { get; set; } = string.Empty;
    public UserRole Role { get; set; }
    public UserStatus Status { get; set; } = UserStatus.Active;
    public DateTime JoinedAt { get; set; } = DateTime.UtcNow;

    public ICollection<Vehicle> Vehicles { get; set; } = new List<Vehicle>();
    public ICollection<Booking> Bookings { get; set; } = new List<Booking>();
    public ICollection<ParkingSession> Sessions { get; set; } = new List<ParkingSession>();
    public ICollection<Notification> Notifications { get; set; } = new List<Notification>();
}
