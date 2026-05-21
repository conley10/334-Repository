using Microsoft.AspNetCore.Mvc;

namespace SmartParking.Features.Auth;

[ApiController]
public class AuthController(MicrosoftOAuthTokenService microsoftOAuth) : ControllerBase
{
    private readonly MicrosoftOAuthTokenService _microsoftOAuth = microsoftOAuth;

    [HttpPost("auth/token")]
    public async Task<ActionResult<TokenResponseDto>> ExchangeToken(
        [FromBody] TokenExchangeRequest request,
        CancellationToken cancellationToken)
    {
        if (request is null || string.IsNullOrWhiteSpace(request.Provider))
            return BadRequest(new { message = "provider is required." });

        var provider = request.Provider.Trim().ToLowerInvariant();
        if (provider != "microsoft")
            return BadRequest(new { message = "Only provider \"microsoft\" is supported." });

        if (string.IsNullOrWhiteSpace(request.Code) || string.IsNullOrWhiteSpace(request.CodeVerifier))
            return BadRequest(new { message = "code and codeVerifier are required." });

        if (string.IsNullOrWhiteSpace(request.RedirectUri))
            return BadRequest(new { message = "redirectUri is required for Microsoft sign-in." });

        if (!_microsoftOAuth.IsConfigured)
            return StatusCode(503, new { message = "Microsoft sign-in is not configured on this server." });

        var (ok, error) = await _microsoftOAuth.ExchangeAuthorizationCodeAsync(
            request.Code.Trim(),
            request.CodeVerifier.Trim(),
            request.RedirectUri.Trim(),
            cancellationToken);

        if (ok is null)
            return BadRequest(new { message = error ?? "Token exchange failed." });

        return Ok(ok);
    }

    [HttpPost("auth/refresh")]
    public async Task<ActionResult<TokenResponseDto>> RefreshToken(
        [FromBody] RefreshTokenRequest request,
        CancellationToken cancellationToken)
    {
        if (request is null || string.IsNullOrWhiteSpace(request.Provider))
            return BadRequest(new { message = "provider is required." });

        var provider = request.Provider.Trim().ToLowerInvariant();
        if (provider != "microsoft")
            return BadRequest(new { message = "Only provider \"microsoft\" is supported." });

        if (string.IsNullOrWhiteSpace(request.RefreshToken))
            return BadRequest(new { message = "refreshToken is required." });

        if (!_microsoftOAuth.IsConfigured)
            return StatusCode(503, new { message = "Microsoft sign-in is not configured on this server." });

        var (ok, error) = await _microsoftOAuth.RefreshAccessTokenAsync(
            request.RefreshToken.Trim(),
            cancellationToken);

        if (ok is null)
            return BadRequest(new { message = error ?? "Token refresh failed." });

        return Ok(ok);
    }
}
