using System.Security.Claims;
using Microsoft.AspNetCore.Http;
using SmartParking.Domain.Common;

namespace SmartParking.Infrastructure.Authentication;

/// <summary>
/// Resolves <see cref="ICurrentUserService.UserId"/> from <see cref="HttpContext.User"/> claims
/// set by <see cref="MockAuthHandler"/> when <c>BYPASS_AUTH=true</c>.
/// </summary>
public class MockCurrentUserService : ICurrentUserService
{
    private readonly IHttpContextAccessor _httpContextAccessor;

    public MockCurrentUserService(IHttpContextAccessor httpContextAccessor)
    {
        _httpContextAccessor = httpContextAccessor;
    }

    public int? UserId
    {
        get
        {
            var user = _httpContextAccessor.HttpContext?.User;
            if (user?.Identity?.IsAuthenticated != true)
                return null;

            var userIdClaim = user.FindFirstValue(ClaimTypes.NameIdentifier);
            if (int.TryParse(userIdClaim, out var userId))
                return userId;

            // Authenticated but missing claim — fall back to seeded mock user.
            return MockAuthDefaults.UserId;
        }
    }
}
