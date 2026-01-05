namespace Ara.Api.Dtos;

public record MeResponse(
    Guid Id,
    string FirstName,
    string LastName,
    string Email,
    string Role,
    string Status,
    DateOnly? VolunteerFrom,
    DateOnly? VolunteerTo
);
