using Ara.Api.Dtos;
using Ara.Domain.Entities;
using ARA.Infrastructure;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace Ara.Api.Controllers;

[Route("api/[controller]")]
[ApiController]
public class AuthController(ARADbContext db) : ControllerBase
{
    [HttpPost("SignUp")]
    public async Task<IActionResult> SignUp([FromBody] SignupRequest request)
    {
        var email = request.Email.Trim().ToLowerInvariant();
        var existsingUser = await db.Users.AnyAsync(u => u.Email == email);
        if (existsingUser)
        {
            return Conflict(new { error = "Email already exists" });
        }

        var user = new User
        {
            FirstName = request.FirstName.Trim(),
            LastName = request.LastName.Trim(),
            Email = email,
            PasswordHash = BCrypt.Net.BCrypt.HashPassword(request.Password),
        };

        db.Users.Add(user);
        await db.SaveChangesAsync();

        return Created(
            string.Empty,
            new { message = "Signup successful; awaiting approval", id = user.Id }
        );
    }

    [HttpPost("Login")]
    public async Task<IActionResult> Login([FromBody] LoginRequest request)
    {
        var email = request.Email.Trim().ToLowerInvariant();

        var user = await db.Users.SingleOrDefaultAsync(u => u.Email == email);
        if (user == null || !BCrypt.Net.BCrypt.Verify(request.Password, user.PasswordHash))
        {
            return Unauthorized(new { error = "Invalid email or password" });
        }

        if (user.Role == Role.Volunteer && user.Status != VolunteerStatus.Approved)
        {
            return StatusCode(403, new { error = "Account not approved" });
        }

        return Ok(
            new
            {
                id = user.Id,
                firstName = user.FirstName,
                lastName = user.LastName,
                email = user.Email,
                role = user.Role,
                status = user.Status
            }
        );
    }
}
