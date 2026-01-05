namespace Ara.Domain.Models;

public class TaskInstance
{
    public Guid Id { get; set; }

    public Guid ShiftInstanceId { get; set; }
    public ShiftInstance ShiftInstance { get; set; } = default!;

    public Guid TaskTemplateId { get; set; }
    public TaskTemplate TaskTemplate { get; set; } = default!;

    public string Name { get; set; } = default!;
    public int? MaxVolunteers { get; set; }

    public List<TaskAssignment> Assignments { get; set; } = new();
}
