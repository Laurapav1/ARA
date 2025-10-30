using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
using Microsoft.Extensions.Options;
using Microsoft.IdentityModel.Tokens;

namespace Ara.Api.Auth;

public interface ITokenService
{
    string CreateToken(Guid userId, string email, string firstName, string lastName, string role);
}

public class TokenService(IOptions<JwtOptions> opts) : ITokenService
{
    private readonly JwtOptions _o = opts.Value;

    public string CreateToken(
        Guid userId,
        string email,
        string firstName,
        string lastName,
        string role
    )
    {
        // Defensive checks (fail fast on bad config)
        if (string.IsNullOrWhiteSpace(_o.Key) || _o.Key.Length < 32)
            throw new InvalidOperationException("JWT signing key missing/too short (>=32 chars).");
        if (string.IsNullOrWhiteSpace(_o.Issuer))
            throw new InvalidOperationException("JWT issuer missing.");
        if (string.IsNullOrWhiteSpace(_o.Audience))
            throw new InvalidOperationException("JWT audience missing.");
        if (_o.AccessTokenMinutes <= 0)
            throw new InvalidOperationException("AccessTokenMinutes must be > 0.");

        // iat (issued-at) must be int64 epoch seconds for best compatibility
        var now = DateTime.UtcNow;
        var epoch = new DateTimeOffset(now).ToUnixTimeSeconds().ToString();

        var claims = new[]
        {
            new Claim(JwtRegisteredClaimNames.Sub, userId.ToString()),
            new Claim(JwtRegisteredClaimNames.Email, email),
            new Claim(JwtRegisteredClaimNames.Iat, epoch, ClaimValueTypes.Integer64),
            new Claim(JwtRegisteredClaimNames.Jti, Guid.NewGuid().ToString()),
            // Nice-to-have identity claims
            new Claim(ClaimTypes.NameIdentifier, userId.ToString()),
            new Claim(ClaimTypes.GivenName, firstName ?? string.Empty),
            new Claim(ClaimTypes.Surname, lastName ?? string.Empty),
            new Claim(ClaimTypes.Name, $"{firstName} {lastName}".Trim()),
            // CRUCIAL: role for [Authorize(Roles="...")]
            new Claim(ClaimTypes.Role, role) // e.g. "Staff" or "Volunteer"
        };

        var key = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(_o.Key));
        var creds = new SigningCredentials(key, SecurityAlgorithms.HmacSha256);

        var jwt = new JwtSecurityToken(
            issuer: _o.Issuer,
            audience: _o.Audience,
            claims: claims,
            notBefore: now,
            expires: now.AddMinutes(_o.AccessTokenMinutes),
            signingCredentials: creds
        );

        return new JwtSecurityTokenHandler().WriteToken(jwt);
    }
}
