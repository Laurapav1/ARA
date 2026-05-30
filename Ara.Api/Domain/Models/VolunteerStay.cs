using Ara.Api.Enums;

namespace Ara.Domain.Models;

public class VolunteerStay
{
    public Guid Id { get; set; }
    public Guid UserId { get; set; }
    public User User { get; set; } = null!;
    public VolunteerStayStatus Status { get; set; } = VolunteerStayStatus.Pending;
    public DateOnly VolunteerFrom { get; set; }
    public DateOnly VolunteerTo { get; set; }
    public DateTime RequestedAt { get; set; } = DateTime.UtcNow;
    public DateTime? ApprovedAt { get; set; }
    public Guid? ApprovedByUserId { get; set; }
    public DateTime? CancelledAt { get; set; }
}
