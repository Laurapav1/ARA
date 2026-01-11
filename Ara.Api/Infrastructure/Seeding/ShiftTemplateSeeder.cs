using Ara.Api.Data;
using Ara.Api.Enums;
using Ara.Domain.Models;
using Microsoft.EntityFrameworkCore;

namespace Ara.Api.Infrastructure.Seeding;

public static class ShiftTemplateSeeder
{
    private static readonly string[] EveningParkNames =
    {
        "Zone A kennels",
        "Zone B & C kennels",
        "Wooden house park",
        "Big park",
        "Between park",
        "New park",
        "Trailer park",
        "A1 park",
        "A2 park",
        "B park",
        "C park",
        "Adoption center",
        "60 stairs park",
        "Paradise park",
        "A cattery",
        "Pool side cattery",
        "Adult side cattery",
        "Laundry",
        "Around trailers",
        "Around meeting room",
        "Main road",
    };

    public static async Task SeedAsync(ARADbContext db)
    {
        // Normalize old data where RequiredVolunteers was defaulted to 0.
        await EnsureRequiredVolunteersDefaultsAsync(db);
        await EnsureEveningParkTasksAsync(db);

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
        var eveningParks = EveningParkNames;
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

    private static async Task EnsureEveningParkTasksAsync(ARADbContext db)
    {
        var templates = await db
            .ShiftTemplates.Include(t => t.Tasks)
            .Where(t => t.ShiftType == ShiftType.Evening)
            .ToListAsync();

        if (templates.Count == 0)
        {
            return;
        }

        var desiredNames = BuildEveningTasks(EveningParkNames, Array.Empty<(string, int?)>())
            .Select(t => t.Name)
            .ToList();

        var comparer = StringComparer.OrdinalIgnoreCase;
        var anyChanges = false;

        foreach (var template in templates)
        {
            var existing = new HashSet<string>(
                template.Tasks.Select(t => t.Name),
                comparer
            );

            var newTasks = new List<TaskTemplate>();
            foreach (var name in desiredNames)
            {
                if (existing.Contains(name))
                {
                    continue;
                }

                var task = new TaskTemplate
                {
                    Id = Guid.NewGuid(),
                    Name = name,
                    MaxVolunteers = null,
                    RequiredVolunteers = 1
                };
                template.Tasks.Add(task);
                newTasks.Add(task);
                anyChanges = true;
            }

            if (newTasks.Count == 0)
            {
                continue;
            }

            var shiftInstances = await db
                .ShiftInstances.Include(s => s.Tasks)
                .Where(s => s.ShiftTemplateId == template.Id)
                .ToListAsync();

            foreach (var shift in shiftInstances)
            {
                var shiftTaskNames = new HashSet<string>(
                    shift.Tasks.Select(t => t.Name),
                    comparer
                );
                foreach (var task in newTasks)
                {
                    if (shiftTaskNames.Contains(task.Name))
                    {
                        continue;
                    }

                    shift.Tasks.Add(
                        new TaskInstance
                        {
                            TaskTemplateId = task.Id,
                            Name = task.Name,
                            MaxVolunteers = task.MaxVolunteers,
                            RequiredVolunteers = task.RequiredVolunteers
                        }
                    );
                    anyChanges = true;
                }
            }
        }

        if (anyChanges)
        {
            await db.SaveChangesAsync();
        }
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
