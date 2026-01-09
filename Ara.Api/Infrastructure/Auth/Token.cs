using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
using Microsoft.Extensions.Options;
using Microsoft.IdentityModel.Tokens;

namespace Ara.Api.Auth;

public interface ITokenService
{
    string CreateToken(Guid userId, string email, string firstName, string lastName, string role);
    string CreateRefreshToken();
    string HashRefreshToken(string refreshToken);
}

public sealed class TokenService : ITokenService
{
    private readonly JwtOptions _o;

    public TokenService(IOptions<JwtOptions> opts)
    {
        _o = opts.Value ?? throw new ArgumentNullException(nameof(opts));
    }

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

        if (userId == Guid.Empty)
            throw new ArgumentException("userId must not be empty.", nameof(userId));
        if (string.IsNullOrWhiteSpace(email))
            throw new ArgumentException("email must not be empty.", nameof(email));
        if (string.IsNullOrWhiteSpace(role))
            throw new ArgumentException("role must not be empty.", nameof(role));

        // iat (issued-at) should be epoch seconds (int64) for best compatibility
        var now = DateTime.UtcNow;
        var epochSeconds = new DateTimeOffset(now).ToUnixTimeSeconds();

        var safeFirst = firstName?.Trim() ?? string.Empty;
        var safeLast = lastName?.Trim() ?? string.Empty;
        var fullName = $"{safeFirst} {safeLast}".Trim();

        var claims = new List<Claim>
        {
            // Standard JWT claims
            new(JwtRegisteredClaimNames.Sub, userId.ToString()),
            new(JwtRegisteredClaimNames.Email, email),
            new(JwtRegisteredClaimNames.Iat, epochSeconds.ToString(), ClaimValueTypes.Integer64),
            new(JwtRegisteredClaimNames.Jti, Guid.NewGuid().ToString()),
            // Useful identity claims for ASP.NET
            new(ClaimTypes.NameIdentifier, userId.ToString()),
            new(ClaimTypes.GivenName, safeFirst),
            new(ClaimTypes.Surname, safeLast),
            new(ClaimTypes.Name, fullName),
            // CRUCIAL: role for [Authorize(Roles="...")]
            new(ClaimTypes.Role, role) // e.g. "Staff" or "Volunteer"
        };

        var signingKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(_o.Key));
        var creds = new SigningCredentials(signingKey, SecurityAlgorithms.HmacSha256);

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

    public string CreateRefreshToken()
    {
        var bytes = new byte[64];
        using var rng = System.Security.Cryptography.RandomNumberGenerator.Create();
        rng.GetBytes(bytes);
        return Convert.ToBase64String(bytes);
    }

    public string HashRefreshToken(string refreshToken)
    {
        if (string.IsNullOrWhiteSpace(refreshToken))
            throw new ArgumentException("refreshToken must not be empty.", nameof(refreshToken));

        using var sha = System.Security.Cryptography.SHA256.Create();
        var hash = sha.ComputeHash(Encoding.UTF8.GetBytes(refreshToken));
        return Convert.ToBase64String(hash);
    }
}
