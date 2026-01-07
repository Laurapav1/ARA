using System.ComponentModel.DataAnnotations;

namespace Ara.Domain.Models;

public class TaskInstance
{
    public Guid Id { get; set; }

    // ── Relations
    public Guid ShiftInstanceId { get; set; }
    public ShiftInstance ShiftInstance { get; set; } = default!;

    public Guid TaskTemplateId { get; set; }
    public TaskTemplate TaskTemplate { get; set; } = default!;

    // ── Task info (copied from template)
    public string Name { get; set; } = default!;
    public int? MaxVolunteers { get; set; }

    public int RequiredVolunteers { get; set; } = 1;

    // ── Completion state (green / undo)
    public DateTime? CompletedAt { get; set; }
    public Guid? CompletedByUserId { get; set; }
    public User? CompletedByUser { get; set; }

    // ── Assignments
    public List<TaskAssignment> Assignments { get; set; } = new();

    [Timestamp]
    public byte[] RowVersion { get; set; } = Array.Empty<byte>();
}
