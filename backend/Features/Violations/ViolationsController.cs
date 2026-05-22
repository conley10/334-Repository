using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace SmartParking.Features.Violations;

[ApiController]
[Authorize(Roles = "Admin")]
public class ViolationsController : ControllerBase
{
    private readonly ViolationService _violationService;

    public ViolationsController(ViolationService violationService)
    {
        _violationService = violationService;
    }

    [HttpGet("violations")]
    public async Task<IActionResult> GetViolations()
    {
        var violations = await _violationService.GetAllViolationsAsync();
        return Ok(violations);
    }
}
