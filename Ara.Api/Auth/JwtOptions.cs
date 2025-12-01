namespace Ara.Api.Auth;

public class JwtOptions
{
    public string Issuer { get; set; } = default!;
    public string Audience { get; set; } = "ara-app"; // ok to keep single-audience
    public string Key { get; set; } = default!;
    public int AccessTokenMinutes { get; set; } = 60; // 1h default
}
