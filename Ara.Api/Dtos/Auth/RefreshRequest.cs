using System.ComponentModel.DataAnnotations;

namespace Ara.Api.Dtos;

public class RefreshRequest
{
    [Required]
    public required string RefreshToken { get; set; }
}
