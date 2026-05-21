using System.Security.Claims;
using Microsoft.AspNetCore.Http;
using SmartParking.Domain.Common;

namespace SmartParking.Infrastructure.Authentication;

/// TEMP MOCK: This is a placeholder to allow parallel development.
/// It will be replaced with a real JWT-based implementation once the Auth feature is complete.
public class MockCurrentUserService : ICurrentUserService
{
    private const int DefaultUserId = 2;

    private readonly IHttpContextAccessor _httpContextAccessor;

    public MockCurrentUserService(IHttpContextAccessor httpContextAccessor)
    {
        _httpContextAccessor = httpContextAccessor;
    }

    public int? UserId
    {
        get
        {
            var userIdClaim = _httpContextAccessor.HttpContext?.User.FindFirstValue(
                ClaimTypes.NameIdentifier
            );

            if (int.TryParse(userIdClaim, out var userId))
                return userId;

            return DefaultUserId;
        }
    }
}
