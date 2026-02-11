using Ara.Api.Enums;

namespace Ara.Api.Dtos;

public record UpdateAnimalDto(
    string Name,
    AnimalGender Gender,
    HandlingLevel HandlingLevel,
    HandlingFlags HandlingFlags,
    bool RequiresCare,
    bool InTreatment,
    DogZone? DogZone,
    CatZone? CatZone,
    string? Picture,
    int? Age,
    string? Breed,
    string? History,
    string? HandlingNotes
);
