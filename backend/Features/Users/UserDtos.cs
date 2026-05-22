namespace SmartParking.Features.Users;

public record UserDto(int UserID, string Name, string Email, string Role);

public record UserProfileUpdateDto(string? Name);
