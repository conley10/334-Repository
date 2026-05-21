using System.Security.Claims;
using System.Text.Encodings.Web;
using Microsoft.AspNetCore.Authentication;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Options;

namespace SmartParking.Infrastructure.Authentication;

/// <summary>
/// Authenticates every request as the seeded John Student when <c>BYPASS_AUTH=true</c>.
/// Registers <see cref="ClaimTypes.NameIdentifier"/>, name, email, and all mock roles on <see cref="HttpContext.User"/>.
/// </summary>
public class MockAuthHandler : AuthenticationHandler<AuthenticationSchemeOptions>
{
    public MockAuthHandler(
        IOptionsMonitor<AuthenticationSchemeOptions> options,
        ILoggerFactory logger,
        UrlEncoder encoder
    )
        : base(options, logger, encoder) { }

    protected override Task<AuthenticateResult> HandleAuthenticateAsync()
    {
        var claims = new List<Claim>
        {
            new(ClaimTypes.NameIdentifier, MockAuthDefaults.UserId.ToString()),
            new(ClaimTypes.Name, MockAuthDefaults.Name),
            new(ClaimTypes.Email, MockAuthDefaults.Email),
        };

        foreach (var role in MockAuthDefaults.Roles)
            claims.Add(new Claim(ClaimTypes.Role, role));

        var identity = new ClaimsIdentity(claims, authenticationType: Scheme.Name);
        var principal = new ClaimsPrincipal(identity);
        var ticket = new AuthenticationTicket(principal, Scheme.Name);

        return Task.FromResult(AuthenticateResult.Success(ticket));
    }

    protected override Task HandleChallengeAsync(AuthenticationProperties properties)
    {
        Response.StatusCode = StatusCodes.Status401Unauthorized;
        Response.ContentType = "application/json";
        return Response.WriteAsync("""{"message":"Authentication required."}""");
    }

    protected override Task HandleForbiddenAsync(AuthenticationProperties properties)
    {
        Response.StatusCode = StatusCodes.Status403Forbidden;
        Response.ContentType = "application/json";
        return Response.WriteAsync("""{"message":"You do not have permission to access this resource."}""");
    }
}
