using Ara.Api.Enums;

namespace Ara.Api.Dtos;

public record AnimalListItemDto(
    Guid Id,
    string Name,
    Species Species,
    string? Picture,
    HandlingLevel HandlingLevel,
    HandlingFlags HandlingFlags,
    bool RequiresCare,
    bool InTreatment
);

public record AnimalDetailsDto(
    Guid Id,
    string Name,
    Species Species,
    AnimalGender Gender,
    string? Picture,
    HandlingLevel HandlingLevel,
    HandlingFlags HandlingFlags,
    string? HandlingNotes,
    int? Age,
    string? Breed,
    string? History,
    DogZone? DogZone,
    CatZone? CatZone,
    bool RequiresCare,
    bool InTreatment
);
