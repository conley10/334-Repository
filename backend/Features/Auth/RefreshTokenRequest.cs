using System.Text.Json.Serialization;

namespace SmartParking.Features.Auth;

public sealed class RefreshTokenRequest
{
    [JsonPropertyName("provider")]
    public string Provider { get; set; } = "";

    [JsonPropertyName("refreshToken")]
    public string RefreshToken { get; set; } = "";
}
