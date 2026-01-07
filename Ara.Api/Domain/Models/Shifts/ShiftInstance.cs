using Ara.Api.Enums;

namespace Ara.Domain.Models;

public class ShiftInstance
{
    public Guid Id { get; set; }

    public DateOnly Date { get; set; }
    public ShiftType ShiftType { get; set; }
    public Season Season { get; set; }
    public TimeOnly StartTime { get; set; }

    public Guid ShiftTemplateId { get; set; }
    public ShiftTemplate ShiftTemplate { get; set; } = default!;

    public List<TaskInstance> Tasks { get; set; } = new();
}
