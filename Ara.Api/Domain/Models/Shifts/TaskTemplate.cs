namespace Ara.Domain.Models;

public class TaskTemplate
{
    public Guid Id { get; set; }

    public Guid ShiftTemplateId { get; set; }
    public ShiftTemplate ShiftTemplate { get; set; } = default!;

    public string Name { get; set; } = default!; // "Zone A", "Big park", etc.
    public int? MaxVolunteers { get; set; } // optional capacity
}
