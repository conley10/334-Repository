using System.Text.Json.Serialization;

namespace SmartParking.Features.Auth;

public sealed class TokenExchangeRequest
{
    [JsonPropertyName("provider")]
    public string Provider { get; set; } = "";

    [JsonPropertyName("code")]
    public string Code { get; set; } = "";

    [JsonPropertyName("codeVerifier")]
    public string CodeVerifier { get; set; } = "";

    /// <summary>Must match the redirect URI used in the Microsoft authorize request (e.g. http://localhost:8080/).</summary>
    [JsonPropertyName("redirectUri")]
    public string? RedirectUri { get; set; }
}
