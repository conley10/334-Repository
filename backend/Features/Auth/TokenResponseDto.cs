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

    /// <summary>Display name from Microsoft id_token (given_name or name claim).</summary>
    [JsonPropertyName("displayName")]
    public string? DisplayName { get; set; }

    /// <summary>Microsoft id_token so the client can read profile claims if needed.</summary>
    [JsonPropertyName("idToken")]
    public string? IdToken { get; set; }
}
