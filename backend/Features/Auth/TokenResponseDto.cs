using System.Text.Json.Serialization;

namespace SmartParking.Features.Auth;

public sealed class TokenResponseDto
{
    [JsonPropertyName("accessToken")]
    public string AccessToken { get; set; } = "";

    [JsonPropertyName("expiresIn")]
    public int? ExpiresIn { get; set; }

    [JsonPropertyName("tokenType")]
    public string TokenType { get; set; } = "Bearer";

    [JsonPropertyName("refreshToken")]
    public string? RefreshToken { get; set; }
}
