using System.ComponentModel.DataAnnotations;

namespace Ara.Api.Dtos;

public class SignupRequest
{
    [Required]
    public required string FirstName { get; set; }

    [Required]
    public required string LastName { get; set; }

    [Required, EmailAddress]
    public required string Email { get; set; }

    [Required, MinLength(6, ErrorMessage = "Password must be at least 6 characters long.")]
    public required string Password { get; set; }

    [Required]
    public DateOnly VolunteerFrom { get; set; }

    [Required]
    public DateOnly VolunteerTo { get; set; }
}
