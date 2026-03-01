using System.Text.Json;
using Ara.Api.Data;
using Ara.Api.Dtos.Information;
using Ara.Domain.Models.Information;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace Ara.Api.Controllers;

[Route("api/[controller]")]
[ApiController]
public class InformationController(ARADbContext db) : ControllerBase
{
    [HttpGet("{key}")]
    [AllowAnonymous]
    public async Task<ActionResult<InformationBlobDto>> Get(string key)
    {
        var normalized = NormalizeKey(key);
        if (normalized is null)
            return BadRequest("Invalid information key.");

        var blob = await db
            .InformationBlobs.AsNoTracking()
            .FirstOrDefaultAsync(x => x.Key == normalized);

        if (blob is null)
            return NotFound();

        JsonElement data;
        try
        {
            using var doc = JsonDocument.Parse(blob.Json);
            data = doc.RootElement.Clone();
        }
        catch (JsonException)
        {
            return Problem("Stored information payload is invalid JSON.");
        }

        return Ok(new InformationBlobDto(blob.Key, data, blob.UpdatedAt));
    }

    [HttpPut("{key}")]
    [Authorize(Roles = "Staff")]
    public async Task<ActionResult<InformationBlobDto>> Put(
        string key,
        UpsertInformationBlobRequest request
    )
    {
        var normalized = NormalizeKey(key);
        if (normalized is null)
            return BadRequest("Invalid information key.");

        var json = request.Data.GetRawText();

        var blob = await db.InformationBlobs.FirstOrDefaultAsync(x => x.Key == normalized);
        if (blob is null)
        {
            blob = new InformationBlob
            {
                Key = normalized,
                Json = json,
                UpdatedAt = DateTime.UtcNow
            };
            db.InformationBlobs.Add(blob);
        }
        else
        {
            blob.Json = json;
            blob.UpdatedAt = DateTime.UtcNow;
        }

        await db.SaveChangesAsync();

        JsonElement data;
        using (var doc = JsonDocument.Parse(blob.Json))
        {
            data = doc.RootElement.Clone();
        }

        return Ok(new InformationBlobDto(blob.Key, data, blob.UpdatedAt));
    }

    private static string? NormalizeKey(string key)
    {
        var normalized = (key ?? string.Empty).Trim().ToLowerInvariant();
        if (normalized.Length is < 1 or > 120)
            return null;
        foreach (var ch in normalized)
        {
            var allowed =
                (ch >= 'a' && ch <= 'z') || (ch >= '0' && ch <= '9') || ch is '_' or '-' or '.';
            if (!allowed)
                return null;
        }
        return normalized;
    }
}
