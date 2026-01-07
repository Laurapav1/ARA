using Ara.Api.Enums;

namespace Ara.Api.Dtos;

public record AssignedVolunteerDto(Guid Id, string FirstName, string LastName);

public record ShiftTaskDto(
    Guid TaskId,
    string Name,
    int? MaxVolunteers,
    int RequiredVolunteers,
    int AssignedCount,
    ShiftTaskStatus Status,
    List<AssignedVolunteerDto> AssignedVolunteers
);

public record ShiftViewDto(
    Guid ShiftId,
    DateOnly Date,
    string ShiftType,
    string Season,
    string StartTime, // "08:00"
    List<ShiftTaskDto> Tasks
);
