using Ara.Api.Enums;

namespace Ara.Domain.Models;

public class Animal
{
    public Guid Id { get; set; }
    public required string Name { get; set; }
    public Species Species { get; set; }
    public AnimalGender Gender { get; set; }
    public CatZone? CatZone { get; set; }
    public DogZone? DogZone { get; set; }
    public HandlingLevel HandlingLevel { get; set; }
    public string? Picture { get; set; }
    public string? HandlingNotes { get; set; }
    public int? Age { get; set; }
    public string? Breed { get; set; }
    public string? History { get; set; }
    public HandlingFlags HandlingFlags { get; set; }
    public AnimalStatus AnimalStatus { get; set; }
    public List<string> TrainingLinks { get; set; } = new();
    public bool RequiresCare { get; set; }
    public bool InTreatment { get; set; }
}
