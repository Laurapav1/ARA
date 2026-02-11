using Ara.Api.Data;
using Ara.Api.Dtos;
using Ara.Api.Enums;
using Ara.Domain.Models;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.ModelBinding;
using Microsoft.EntityFrameworkCore;

namespace Ara.Api.Controllers;

[Route("api/[controller]")]
[ApiController]
public class AnimalsController(ARADbContext db) : ControllerBase
{
    // GET /animals?species=Dog&filter=All&search=
    [HttpGet]
    public async Task<ActionResult<IReadOnlyList<AnimalListItemDto>>> GetAnimals(
        [FromQuery, BindRequired] Species species,
        [FromQuery] AnimalFilter filter = AnimalFilter.All,
        [FromQuery] string? search = null
    )
    {
        var query = db
            .Animals.AsNoTracking()
            .Where(x => x.Species == species && x.AnimalStatus == AnimalStatus.AtAra);

        query = filter switch
        {
            AnimalFilter.CareRequired => query.Where(x => x.RequiresCare),
            AnimalFilter.InTreatment => query.Where(x => x.InTreatment),
            _ => query, // all
        };

        if (!string.IsNullOrWhiteSpace(search))
        {
            var term = search.Trim();
            query = query.Where(a => a.Name.Contains(term));
        }

        query = query.OrderBy(a => a.Name);

        var animals = await query
            .Select(a => new AnimalListItemDto(
                a.Id,
                a.Name,
                a.Species,
                a.Picture,
                a.HandlingLevel,
                a.HandlingFlags,
                a.RequiresCare,
                a.InTreatment
            ))
            .ToListAsync();

        return Ok(animals);
    }

    // GET /api/animals/{id}
    [HttpGet("{id:guid}")]
    public async Task<ActionResult<AnimalDetailsDto>> GetAnimal(Guid id)
    {
        var animal = await db.Animals.AsNoTracking().FirstOrDefaultAsync(a => a.Id == id);

        if (animal is null)
            return NotFound();

        var dto = new AnimalDetailsDto(
            animal.Id,
            animal.Name,
            animal.Species,
            animal.Gender,
            animal.Picture,
            animal.HandlingLevel,
            animal.HandlingFlags,
            animal.HandlingNotes,
            animal.Age,
            animal.Breed,
            animal.History,
            animal.DogZone,
            animal.CatZone,
            animal.RequiresCare,
            animal.InTreatment
        );

        return Ok(dto);
    }

    [Authorize(Roles = "Staff")]
    [HttpPost]
    public async Task<ActionResult<Guid>> CreateAnimal(CreateAnimalDto dto)
    {
        // basic guard
        if (dto.Species == Species.Dog && dto.CatZone is not null)
            return BadRequest("Cats zones cannot be set for dogs.");

        if (dto.Species == Species.Cat && dto.DogZone is not null)
            return BadRequest("Dog zones cannot be set for cats.");

        if (dto.Species == Species.Dog && dto.DogZone is null)
            return BadRequest("Dog zone is required for dogs.");

        if (dto.Species == Species.Cat && dto.CatZone is null)
            return BadRequest("Cat zone is required for cats.");

        var animal = new Animal
        {
            Id = Guid.NewGuid(),
            Name = dto.Name,
            Species = dto.Species,
            Gender = dto.Gender,
            HandlingLevel = dto.HandlingLevel,
            HandlingFlags = dto.HandlingFlags,
            RequiresCare = dto.RequiresCare,
            InTreatment = dto.InTreatment,
            DogZone = dto.DogZone,
            CatZone = dto.CatZone,
            Picture = dto.Picture,
            Age = dto.Age,
            Breed = dto.Breed,
            History = dto.History,
            HandlingNotes = dto.HandlingNotes,
            AnimalStatus = AnimalStatus.AtAra
        };

        db.Animals.Add(animal);
        await db.SaveChangesAsync();

        return CreatedAtAction(nameof(GetAnimal), new { id = animal.Id }, animal.Id);
    }

    [Authorize(Roles = "Staff")]
    [HttpPut("{id:guid}")]
    public async Task<IActionResult> UpdateAnimal(Guid id, UpdateAnimalDto dto)
    {
        var animal = await db.Animals.FindAsync(id);

        if (animal is null)
            return NotFound();

        animal.Name = dto.Name;
        animal.Gender = dto.Gender;
        animal.HandlingLevel = dto.HandlingLevel;
        animal.HandlingFlags = dto.HandlingFlags;
        animal.RequiresCare = dto.RequiresCare;
        animal.InTreatment = dto.InTreatment;
        animal.DogZone = dto.DogZone;
        animal.CatZone = dto.CatZone;
        animal.Picture = dto.Picture;
        animal.Age = dto.Age;
        animal.Breed = dto.Breed;
        animal.History = dto.History;
        animal.HandlingNotes = dto.HandlingNotes;

        await db.SaveChangesAsync();
        return NoContent();
    }

    [Authorize(Roles = "Staff")]
    [HttpDelete("{id:guid}")]
    public async Task<IActionResult> DeleteAnimal(Guid id)
    {
        var animal = await db.Animals.FindAsync(id);

        if (animal is null)
            return NotFound();

        animal.AnimalStatus = AnimalStatus.Remove;
        await db.SaveChangesAsync();

        return NoContent();
    }
}
