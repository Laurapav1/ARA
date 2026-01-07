namespace Ara.Domain.Models;

public class TaskAssignment
{
    public Guid Id { get; set; }

    public Guid TaskInstanceId { get; set; }
    public TaskInstance TaskInstance { get; set; } = default!;

    public Guid VolunteerId { get; set; }
    public User Volunteer { get; set; } = default!;

    public DateTime CreatedAt { get; set; } = DateTime.UtcNow; // optional but useful
}
