using System.Net.Http.Headers;
using System.Text;
using System.Text.Json;

namespace SmartParking.Features.Auth;

public sealed class MicrosoftOAuthTokenService(HttpClient httpClient, IConfiguration configuration, ILogger<MicrosoftOAuthTokenService> logger)
{
    private readonly HttpClient _httpClient = httpClient;
    private readonly IConfiguration _configuration = configuration;
    private readonly ILogger<MicrosoftOAuthTokenService> _logger = logger;

    /// <summary>
    /// Prefer first non-empty value. Docker/env can set keys to "" which overrides appsettings;
    /// <c>??</c> only skips <c>null</c>, so we must ignore whitespace-only strings.
    /// </summary>
    private static string? FirstNonEmpty(params string?[] candidates)
    {
        foreach (var c in candidates)
        {
            if (!string.IsNullOrWhiteSpace(c))
                return c.Trim();
        }

        return null;
    }

    /// <summary>
    /// Tenant/client from appsettings (<c>MicrosoftAuth:*</c>), Docker env (<c>MicrosoftAuth__*</c>),
    /// or the same flat names as Flutter (<c>MICROSOFT_TENANT_ID</c> / <c>MICROSOFT_CLIENT_ID</c>).
    /// </summary>
    private string? TenantId => SanitizeId(FirstNonEmpty(
        _configuration["MicrosoftAuth:TenantId"],
        _configuration["MICROSOFT_TENANT_ID"]));

    private string? ClientId => SanitizeId(FirstNonEmpty(
        _configuration["MicrosoftAuth:ClientId"],
        _configuration["MICROSOFT_CLIENT_ID"]));

    private static string? SanitizeId(string? value)
    {
        if (string.IsNullOrWhiteSpace(value))
            return null;

        var trimmed = value.Trim().Trim('"', '\'');
        const string loginHost = "https://login.microsoftonline.com/";
        if (trimmed.StartsWith(loginHost, StringComparison.OrdinalIgnoreCase))
        {
            var rest = trimmed[loginHost.Length..];
            var slash = rest.IndexOf('/');
            trimmed = slash < 0 ? rest : rest[..slash];
        }

        return trimmed.Trim();
    }

    private string? ClientSecret => FirstNonEmpty(_configuration["MicrosoftAuth:ClientSecret"]);

    public bool IsConfigured =>
        !string.IsNullOrWhiteSpace(TenantId)
        && !string.IsNullOrWhiteSpace(ClientId);

    public async Task<(TokenResponseDto? Ok, string? Error)> ExchangeAuthorizationCodeAsync(
        string authorizationCode,
        string codeVerifier,
        string redirectUri,
        CancellationToken cancellationToken = default)
    {
        if (!IsConfigured)
            return (null, "Microsoft sign-in is not configured on the server (MicrosoftAuth:TenantId / ClientId).");

        var tenantId = TenantId!.Trim();
        var clientId = ClientId!.Trim();
        var clientSecret = ClientSecret;
        var tokenEndpoint = $"https://login.microsoftonline.com/{tenantId}/oauth2/v2.0/token";

        var form = new Dictionary<string, string>
        {
            ["client_id"] = clientId,
            ["grant_type"] = "authorization_code",
            ["code"] = authorizationCode,
            ["redirect_uri"] = redirectUri,
            ["code_verifier"] = codeVerifier,
            ["scope"] = "openid profile email offline_access",
        };

        if (!string.IsNullOrEmpty(clientSecret))
            form["client_secret"] = clientSecret;

        using var content = new FormUrlEncodedContent(form);
        content.Headers.ContentType = new MediaTypeHeaderValue("application/x-www-form-urlencoded");

        HttpResponseMessage response;
        try
        {
            response = await _httpClient.PostAsync(tokenEndpoint, content, cancellationToken);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Microsoft token HTTP request failed.");
            return (null, "Could not reach Microsoft to complete sign-in.");
        }

        var body = await response.Content.ReadAsStringAsync(cancellationToken);

        if (!response.IsSuccessStatusCode)
        {
            var msg = TryReadOAuthError(body) ?? $"Microsoft token endpoint returned {(int)response.StatusCode}.";
            _logger.LogWarning("Microsoft token exchange failed: {Message}. Body: {Body}", msg, body);
            return (null, msg);
        }

        return ParseTokenResponse(body);
    }

    public async Task<(TokenResponseDto? Ok, string? Error)> RefreshAccessTokenAsync(
        string refreshToken,
        CancellationToken cancellationToken = default)
    {
        if (!IsConfigured)
            return (null, "Microsoft sign-in is not configured on the server (MicrosoftAuth:TenantId / ClientId).");

        if (string.IsNullOrWhiteSpace(refreshToken))
            return (null, "refreshToken is required.");

        var tenantId = TenantId!.Trim();
        var clientId = ClientId!.Trim();
        var clientSecret = ClientSecret;
        var tokenEndpoint = $"https://login.microsoftonline.com/{tenantId}/oauth2/v2.0/token";

        var form = new Dictionary<string, string>
        {
            ["client_id"] = clientId,
            ["grant_type"] = "refresh_token",
            ["refresh_token"] = refreshToken.Trim(),
            ["scope"] = "openid profile email offline_access",
        };

        if (!string.IsNullOrEmpty(clientSecret))
            form["client_secret"] = clientSecret;

        using var content = new FormUrlEncodedContent(form);
        content.Headers.ContentType = new MediaTypeHeaderValue("application/x-www-form-urlencoded");

        HttpResponseMessage response;
        try
        {
            response = await _httpClient.PostAsync(tokenEndpoint, content, cancellationToken);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Microsoft refresh token HTTP request failed.");
            return (null, "Could not reach Microsoft to refresh sign-in.");
        }

        var body = await response.Content.ReadAsStringAsync(cancellationToken);

        if (!response.IsSuccessStatusCode)
        {
            var msg = TryReadOAuthError(body) ?? $"Microsoft token endpoint returned {(int)response.StatusCode}.";
            _logger.LogWarning("Microsoft token refresh failed: {Message}. Body: {Body}", msg, body);
            return (null, msg);
        }

        return ParseTokenResponse(body);
    }

    private static (TokenResponseDto? Ok, string? Error) ParseTokenResponse(string body)
    {
        using var doc = JsonDocument.Parse(body);
        var root = doc.RootElement;

        var accessToken = root.TryGetProperty("access_token", out var at) ? at.GetString() : null;
        var idToken = root.TryGetProperty("id_token", out var idt) ? idt.GetString() : null;
        var chosen = !string.IsNullOrEmpty(accessToken) ? accessToken : idToken;

        if (string.IsNullOrEmpty(chosen))
            return (null, "Microsoft did not return an access token.");

        var expiresIn = root.TryGetProperty("expires_in", out var exp) && exp.TryGetInt32(out var secs)
            ? secs
            : (int?)null;

        var refreshToken = root.TryGetProperty("refresh_token", out var rt) ? rt.GetString() : null;

        var displayName = DisplayNameFromIdToken(idToken) ?? DisplayNameFromIdToken(accessToken);

        return (new TokenResponseDto
        {
            AccessToken = chosen,
            ExpiresIn = expiresIn,
            TokenType = "Bearer",
            RefreshToken = refreshToken,
            DisplayName = displayName,
            IdToken = idToken,
        }, null);
    }

    /// <summary>Reads name claims from a Microsoft id_token JWT payload (no signature validation).</summary>
    private static string? DisplayNameFromIdToken(string? idToken)
    {
        if (string.IsNullOrWhiteSpace(idToken))
            return null;

        var parts = idToken.Split('.');
        if (parts.Length < 2)
            return null;

        try
        {
            var payloadJson = Encoding.UTF8.GetString(Base64UrlDecode(parts[1]));
            using var doc = JsonDocument.Parse(payloadJson);
            var root = doc.RootElement;

            if (root.TryGetProperty("given_name", out var given) && given.ValueKind == JsonValueKind.String)
            {
                var g = given.GetString()?.Trim();
                if (!string.IsNullOrEmpty(g))
                    return g;
            }

            if (root.TryGetProperty("name", out var name) && name.ValueKind == JsonValueKind.String)
            {
                var n = name.GetString()?.Trim();
                if (!string.IsNullOrEmpty(n))
                    return n;
            }

            if (root.TryGetProperty("preferred_username", out var preferred)
                && preferred.ValueKind == JsonValueKind.String)
            {
                var p = preferred.GetString()?.Trim();
                if (!string.IsNullOrEmpty(p))
                    return p.Split('@').FirstOrDefault()?.Trim();
            }

            if (root.TryGetProperty("email", out var email) && email.ValueKind == JsonValueKind.String)
            {
                var e = email.GetString()?.Trim();
                if (!string.IsNullOrEmpty(e))
                    return e.Split('@').FirstOrDefault()?.Trim();
            }
        }
        catch
        {
            return null;
        }

        return null;
    }

    private static byte[] Base64UrlDecode(string input)
    {
        var padded = input.Replace('-', '+').Replace('_', '/');
        switch (padded.Length % 4)
        {
            case 2: padded += "=="; break;
            case 3: padded += "="; break;
        }

        return Convert.FromBase64String(padded);
    }

    private static string? TryReadOAuthError(string json)
    {
        try
        {
            using var doc = JsonDocument.Parse(json);
            var root = doc.RootElement;
            if (root.TryGetProperty("error_description", out var d) && d.ValueKind == JsonValueKind.String)
                return d.GetString();
            if (root.TryGetProperty("error", out var e) && e.ValueKind == JsonValueKind.String)
                return e.GetString();
        }
        catch
        {
            // ignore
        }

        return null;
    }
}
