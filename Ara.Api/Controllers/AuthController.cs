using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using Ara.Api.Auth;
using Ara.Api.Data;
using Ara.Api.Dtos;
using Ara.Api.Enums;
using Ara.Domain.Models;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Options;

namespace Ara.Api.Controllers;

[Route("api/[controller]")]
[ApiController]
public class AuthController(ARADbContext db, ITokenService tokens, IOptions<JwtOptions> jwtOptions)
    : ControllerBase
{
    private readonly ITokenService _tokens = tokens;
    private readonly JwtOptions _jwt = jwtOptions.Value;

    [HttpPost("signUp")]
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
            CreatedAt = DateTime.UtcNow,
            VolunteerFrom = request.VolunteerFrom,
            VolunteerTo = request.VolunteerTo
        };

        db.Users.Add(user);
        await db.SaveChangesAsync();

        return Created(
            string.Empty,
            new { message = "Signup successful; awaiting approval", id = user.Id }
        );
    }

    [HttpPost("login")]
    [AllowAnonymous]
    public async Task<IActionResult> Login([FromBody] LoginRequest request)
    {
        var email = request.Email.Trim().ToLowerInvariant();

        var user = await db.Users.SingleOrDefaultAsync(u => u.Email == email);
        if (user == null || !BCrypt.Net.BCrypt.Verify(request.Password, user.PasswordHash))
        {
            return Unauthorized(new { error = "Invalid email or password" });
        }

        var shelterTimeZone = TimeZoneInfo.FindSystemTimeZoneById("Europe/Lisbon");
        var nowInShelter = TimeZoneInfo.ConvertTimeFromUtc(DateTime.UtcNow, shelterTimeZone);
        var today = DateOnly.FromDateTime(nowInShelter);

        // Volunteers must be approved to log in
        if (user.Role == Role.Volunteer && user.Status != VolunteerStatus.Approved)
        {
            return StatusCode(403, new { error = "Account not approved" });
        }

        var token = _tokens.CreateToken(
            user.Id,
            user.Email,
            user.FirstName,
            user.LastName,
            user.Role.ToString()
        );

        var refreshToken = _tokens.CreateRefreshToken();
        user.RefreshTokenHash = _tokens.HashRefreshToken(refreshToken);
        user.RefreshTokenCreatedAt = DateTime.UtcNow;
        user.RefreshTokenExpiresAt = DateTime.UtcNow.AddDays(_jwt.RefreshTokenDays);
        user.RefreshTokenRevokedAt = null;
        await db.SaveChangesAsync();

        return Ok(new AuthResponse(token, refreshToken, BuildMeResponse(user)));
    }

    [HttpGet("me")]
    [Authorize]
    public async Task<ActionResult<MeResponse>> Me()
    {
        var userIdStr =
            User.FindFirstValue(ClaimTypes.NameIdentifier)
            ?? User.FindFirstValue(JwtRegisteredClaimNames.Sub);

        if (!Guid.TryParse(userIdStr, out var userId))
            return Unauthorized(new { error = "Invalid token (no user id)." });

        var u = await db.Users.AsNoTracking().SingleOrDefaultAsync(x => x.Id == userId);
        if (u is null)
            return Unauthorized(new { error = "User not found." });

        return Ok(BuildMeResponse(u));
    }

    [HttpPost("refresh")]
    [AllowAnonymous]
    public async Task<ActionResult<AuthResponse>> Refresh([FromBody] RefreshRequest request)
    {
        var tokenHash = _tokens.HashRefreshToken(request.RefreshToken);

        var user = await db.Users.SingleOrDefaultAsync(u => u.RefreshTokenHash == tokenHash);
        if (user is null)
            return Unauthorized(new { error = "Invalid refresh token." });

        if (user.RefreshTokenRevokedAt is not null)
            return Unauthorized(new { error = "Refresh token revoked." });

        if (user.RefreshTokenExpiresAt is not null && user.RefreshTokenExpiresAt < DateTime.UtcNow)
            return Unauthorized(new { error = "Refresh token expired." });

        var accessToken = _tokens.CreateToken(
            user.Id,
            user.Email,
            user.FirstName,
            user.LastName,
            user.Role.ToString()
        );

        var newRefreshToken = _tokens.CreateRefreshToken();
        user.RefreshTokenHash = _tokens.HashRefreshToken(newRefreshToken);
        user.RefreshTokenCreatedAt = DateTime.UtcNow;
        user.RefreshTokenExpiresAt = DateTime.UtcNow.AddDays(_jwt.RefreshTokenDays);
        user.RefreshTokenRevokedAt = null;
        await db.SaveChangesAsync();

        return Ok(new AuthResponse(accessToken, newRefreshToken, BuildMeResponse(user)));
    }

    [HttpPost("logout")]
    [Authorize]
    public async Task<IActionResult> Logout()
    {
        var userIdStr =
            User.FindFirstValue(ClaimTypes.NameIdentifier)
            ?? User.FindFirstValue(JwtRegisteredClaimNames.Sub);

        if (!Guid.TryParse(userIdStr, out var userId))
            return Unauthorized(new { error = "Invalid token (no user id)." });

        var user = await db.Users.SingleOrDefaultAsync(u => u.Id == userId);
        if (user is null)
            return Ok(new { message = "Logged out." });

        user.RefreshTokenRevokedAt = DateTime.UtcNow;
        await db.SaveChangesAsync();
        return Ok(new { message = "Logged out." });
    }

    private static MeResponse BuildMeResponse(User u)
    {
        return new MeResponse(
            u.Id,
            u.FirstName,
            u.LastName,
            u.Email,
            u.Role.ToString(),
            u.Status.ToString(),
            u.VolunteerFrom,
            u.VolunteerTo
        );
    }
}
