using System.ComponentModel.DataAnnotations;

namespace Ara.Api.Dtos;

public class CreateVolunteerStayRequest
{
    [Required]
    public DateOnly VolunteerFrom { get; set; }

    [Required]
    public DateOnly VolunteerTo { get; set; }
}
