using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace SmartParking.Features.Users;

[ApiController]
[Authorize]
public class UsersController : ControllerBase
{
    [HttpGet("users/me")]
    public IActionResult GetMe() => Ok();

    [HttpPatch("users/me")]
    public IActionResult UpdateMe() => Ok();
}
