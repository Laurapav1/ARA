using Ara.Api.Data;
using Ara.Api.Enums;
using Ara.Domain.Models;
using Microsoft.EntityFrameworkCore;

namespace Ara.Api.Infrastructure.Seeding;

public static class ShiftTemplateSeeder
{
    public static async Task SeedAsync(ARADbContext db)
    {
        // Normalize old data where RequiredVolunteers was defaulted to 0.
        await EnsureRequiredVolunteersDefaultsAsync(db);

        if (await db.ShiftTemplates.AnyAsync())
            return;

        // --- MORNING TASKS (cleaning/catteries) ---
        var morningTasks = new (string Name, int? Max)[]
        {
            ("Zone A", null),
            ("Zone B", null),
            ("Zone Z", null),
            ("A Cattery", null),
            ("Pool side cattery", null),
            ("Adult side cattery", null),
        };

        // --- EVENING TASKS (parks + special) ---
        var eveningParks = new[]
        {
            "Wooden house park",
            "Big park",
            "Between park",
        };
        var eveningTasks = BuildEveningTasks(
            eveningParks,
            new (string Name, int? Max)[]
            {
                // Special duties (MVP: shown always; later you can filter by weekday)
                ("End of shift checks", 1),
                ("Trash prep (Mon/Fri)", null),
                ("Trash run helpers", 2),
            }
        );

        // Winter
        var morningWinter = CreateTemplate(
            ShiftType.Morning,
            Season.Winter,
            new TimeOnly(8, 0),
            "Morning (Winter)",
            morningTasks
        );
        var eveningWinter = CreateTemplate(
            ShiftType.Evening,
            Season.Winter,
            new TimeOnly(16, 0),
            "Evening (Winter)",
            eveningTasks
        );

        // Summer (adjust start times to your real times)
        var morningSummer = CreateTemplate(
            ShiftType.Morning,
            Season.Summer,
            new TimeOnly(7, 0),
            "Morning (Summer)",
            morningTasks
        );
        var eveningSummer = CreateTemplate(
            ShiftType.Evening,
            Season.Summer,
            new TimeOnly(17, 0),
            "Evening (Summer)",
            eveningTasks
        );

        db.ShiftTemplates.AddRange(morningWinter, eveningWinter, morningSummer, eveningSummer);
        await db.SaveChangesAsync();
    }

    private static async Task EnsureRequiredVolunteersDefaultsAsync(ARADbContext db)
    {
        var templates = await db.TaskTemplates.Where(t => t.RequiredVolunteers == 0).ToListAsync();
        foreach (var t in templates)
        {
            t.RequiredVolunteers = 1;
        }

        var instances = await db.TaskInstances.Where(t => t.RequiredVolunteers == 0).ToListAsync();
        foreach (var t in instances)
        {
            t.RequiredVolunteers = 1;
        }

        if (templates.Count > 0 || instances.Count > 0)
        {
            await db.SaveChangesAsync();
        }
    }

    private static ShiftTemplate CreateTemplate(
        ShiftType type,
        Season season,
        TimeOnly startTime,
        string title,
        (string Name, int? Max)[] tasks
    )
    {
        var t = new ShiftTemplate
        {
            Id = Guid.NewGuid(),
            ShiftType = type,
            Season = season,
            StartTime = startTime,
            Title = title,
        };

        foreach (var (name, max) in tasks)
        {
            t.Tasks.Add(
                new TaskTemplate
                {
                    Id = Guid.NewGuid(),
                    Name = name,
                    MaxVolunteers = max
                }
            );
        }

        return t;
    }

    private static (string Name, int? Max)[] BuildEveningTasks(
        IEnumerable<string> parks,
        (string Name, int? Max)[] specials
    )
    {
        var tasks = new List<(string Name, int? Max)>();
        foreach (var park in parks)
        {
            tasks.Add(($"{park} - Water", null));
            tasks.Add(($"{park} - Cleaning", null));
        }

        tasks.AddRange(specials);
        return tasks.ToArray();
    }
}
