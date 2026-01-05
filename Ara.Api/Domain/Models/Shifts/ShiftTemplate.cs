using Ara.Api.Enums;

namespace Ara.Domain.Models;

public class ShiftTemplate
{
    public Guid Id { get; set; }
    public ShiftType ShiftType { get; set; }
    public Season Season { get; set; }

    public TimeOnly StartTime { get; set; } // e.g. 08:00
    public string Title { get; set; } = string.Empty;

    public List<TaskTemplate> Tasks { get; set; } = new();
}
