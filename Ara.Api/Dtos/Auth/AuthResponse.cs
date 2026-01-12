namespace Ara.Api.Dtos;

public record AuthResponse(string Token, string RefreshToken, MeResponse User);
