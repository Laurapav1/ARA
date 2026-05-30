namespace Ara.Api.Dtos;

public record VolunteerStayResponse(
    Guid Id,
    Guid UserId,
    string FirstName,
    string LastName,
    string Email,
    string Status,
    DateTime CreatedAt,
    DateOnly VolunteerFrom,
    DateOnly VolunteerTo,
    bool IsReturning,
    int PreviousStayCount,
    DateOnly? LastStayFrom,
    DateOnly? LastStayTo
);

public record MyVolunteerStayResponse(
    Guid Id,
    string Status,
    DateOnly VolunteerFrom,
    DateOnly VolunteerTo,
    DateTime RequestedAt
);
