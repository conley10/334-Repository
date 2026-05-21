using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using SmartParking.Domain.Common;
using SmartParking.Domain.Entities;
using SmartParking.Infrastructure.Data;

namespace SmartParking.Features.Users;

[ApiController]
[Authorize]
public class UsersController : ControllerBase
{
    private readonly AppDbContext _context;
    private readonly ICurrentUserService _currentUser;

    public UsersController(AppDbContext context, ICurrentUserService currentUser)
    {
        _context = context;
        _currentUser = currentUser;
    }

    [HttpGet("users/me")]
    public async Task<ActionResult<UserDto>> GetMe()
    {
        var user = await FindCurrentUserAsync();
        if (user is null)
            return Unauthorized();

        return Ok(ToDto(user));
    }

    [HttpPatch("users/me")]
    public async Task<ActionResult<UserDto>> UpdateMe([FromBody] UserProfileUpdateDto update)
    {
        var user = await FindCurrentUserAsync();
        if (user is null)
            return Unauthorized();

        if (string.IsNullOrWhiteSpace(update.Name))
            return BadRequest(new { message = "Name is required." });

        user.Name = update.Name.Trim();
        await _context.SaveChangesAsync();

        return Ok(ToDto(user));
    }

    private async Task<User?> FindCurrentUserAsync()
    {
        var userId = _currentUser.UserId;
        if (userId is null)
            return null;

        return await _context.Users.FirstOrDefaultAsync(u => u.UserID == userId.Value);
    }

    private static UserDto ToDto(User user) =>
        new(user.UserID, user.Name, user.Email, user.Role.ToString().ToLower());
}
