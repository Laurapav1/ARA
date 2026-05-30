using System.ComponentModel.DataAnnotations;
using Ara.Api.Enums;

namespace Ara.Domain.Models;

public class User
{
    public Guid Id { get; set; }
    public required string FirstName { get; set; }
    public required string LastName { get; set; }

    [Required, EmailAddress]
    public required string Email { get; set; }

    [Required]
    public required string PasswordHash { get; set; }
    public Role Role { get; set; } = Role.Volunteer;
    public VolunteerStatus Status { get; set; } = VolunteerStatus.Pending;
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    public DateTime? UpdatedAt { get; set; }
    public ICollection<VolunteerStay> VolunteerStays { get; set; } = [];

    // Refresh token (single-device for now)
    public string? RefreshTokenHash { get; set; }
    public DateTime? RefreshTokenCreatedAt { get; set; }
    public DateTime? RefreshTokenExpiresAt { get; set; }
    public DateTime? RefreshTokenRevokedAt { get; set; }
}
