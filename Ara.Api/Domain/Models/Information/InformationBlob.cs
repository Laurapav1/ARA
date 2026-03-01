namespace Ara.Domain.Models.Information;

public class InformationBlob
{
    public required string Key { get; set; }
    public required string Json { get; set; }
    public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;
}
