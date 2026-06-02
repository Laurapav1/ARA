namespace Ara.Api.Dtos;

public record ChangePasswordRequest(string CurrentPassword, string NewPassword);
