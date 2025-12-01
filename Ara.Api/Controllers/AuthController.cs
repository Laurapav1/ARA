using Ara.Api.Auth;
using Ara.Api.Data;
using Ara.Api.Dtos;
using Ara.Api.Enums;
using Ara.Domain.Models;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace Ara.Api.Controllers;

[Route("api/[controller]")]
[ApiController]
public class AuthController(ARADbContext db) : ControllerBase
{
    [HttpPost("SignUp")]
    [AllowAnonymous]
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
            Role = Role.Volunteer,
            Status = VolunteerStatus.Pending,
            CreatedAt = DateTime.UtcNow
        };

        db.Users.Add(user);
        await db.SaveChangesAsync();

        return Created(
            string.Empty,
            new { message = "Signup successful; awaiting approval", id = user.Id }
        );
    }

    [HttpPost("Login")]
    [AllowAnonymous]
    public async Task<IActionResult> Login(
        [FromBody] LoginRequest request,
        [FromServices] ITokenService tokens
    )
    {
        var email = request.Email.Trim().ToLowerInvariant();

        var user = await db.Users.SingleOrDefaultAsync(u => u.Email == email);
        if (user == null || !BCrypt.Net.BCrypt.Verify(request.Password, user.PasswordHash))
        {
            return Unauthorized(new { error = "Invalid email or password" });
        }

        // Volunteers must be approved to log in
        if (user.Role == Role.Volunteer && user.Status != VolunteerStatus.Approved)
        {
            return StatusCode(403, new { error = "Account not approved" });
        }

        // Issue token with role claim (Staff or Volunteer)
        var token = tokens.CreateToken(
            user.Id,
            user.Email,
            user.FirstName,
            user.LastName,
            user.Role.ToString()
        );

        return Ok(
            new
            {
                token,
                user = new
                {
                    id = user.Id,
                    firstName = user.FirstName,
                    lastName = user.LastName,
                    email = user.Email,
                    role = user.Role,
                    status = user.Status
                }
            }
        );
    }
}
