using Microsoft.AspNetCore.Mvc;

namespace SmartParking.Features.Auth;

[ApiController]
public class AuthController : ControllerBase
{
    [HttpPost("auth/token")]
    public IActionResult GetToken() => Ok();
}
