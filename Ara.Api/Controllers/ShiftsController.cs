using System.Security.Claims;
using Ara.Api.Data;
using Ara.Api.Dtos;
using Ara.Api.Enums;
using Ara.Api.Shifts;
using Ara.Domain.Models;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace Ara.Api.Controllers;

[Route("api/[controller]")]
[ApiController]
[Authorize]
public class ShiftsController(ARADbContext db) : ControllerBase
{
    // GET /api/shifts?date=2026-01-05&type=morning
    [HttpGet]
    public async Task<ActionResult<ShiftViewDto>> GetShift(
        [FromQuery] string date,
        [FromQuery] ShiftType type
    )
    {
        if (string.IsNullOrEmpty(date) || !DateOnly.TryParse(date, out var parsedDate))
            return BadRequest(new { error = "Invalid date. Use yyyy-MM-dd (e.g. 2026-01-07)." });

        if (!Enum.IsDefined(typeof(ShiftType), type))
            return BadRequest(
                new { error = "Invalid shift type. Use 0 for Morning or 1 for Evening." }
            );

        var shift = await GetOrCreateShiftInstance(parsedDate, type);

        // Load tasks + assignments + volunteers
        var loaded = await db
            .ShiftInstances.AsNoTracking()
            .Where(s => s.Id == shift.Id)
            .Include(s => s.Tasks)
            .ThenInclude(t => t.Assignments)
            .ThenInclude(a => a.Volunteer)
            .SingleAsync();

        var tasks = FilterEveningSplitTasks(loaded);

        var dto = new ShiftViewDto(
            loaded.Id,
            loaded.Date,
            loaded.ShiftType.ToString(),
            loaded.Season.ToString(),
            loaded.StartTime.ToString("HH:mm"),
            tasks
                .OrderBy(t => t.Name)
                .Select(t =>
                {
                    var assignedCount = t.Assignments.Count;
                    return new ShiftTaskDto(
                        t.Id,
                        t.Name,
                        t.MaxVolunteers,
                        t.RequiredVolunteers,
                        assignedCount,
                        GetTaskStatus(t, assignedCount),
                        t.Assignments.OrderBy(a => a.CreatedAt)
                            .Select(a => new AssignedVolunteerDto(
                                a.Volunteer.Id,
                                a.Volunteer.FirstName,
                                a.Volunteer.LastName
                            ))
                            .ToList()
                    );
                })
                .ToList()
        );

        return Ok(dto);
    }

    // POST /api/shifts/{shiftId}/tasks/{taskId}/join
    [HttpPost("{shiftId:Guid}/tasks/{taskId:Guid}/join")]
    public async Task<IActionResult> JoinTask(Guid shiftId, Guid taskId)
    {
        var volunteerId = GetUserIdOrThrow();

        // Load the task instance and validate it belongs to this shift
        var task = await db
            .TaskInstances.Include(t => t.ShiftInstance)
            .SingleOrDefaultAsync(t => t.Id == taskId);

        if (task is null)
            return NotFound(new { error = "Task not found." });
        if (task.ShiftInstanceId != shiftId)
            return BadRequest(new { error = "Task does not belong to the shift." });

        // Optional: enforce volunteer constraints (approved + period)
        var user = await db.Users.SingleAsync(u => u.Id == volunteerId);

        if (user.Role == Role.Volunteer && user.Status != VolunteerStatus.Approved)
            return StatusCode(403, new { error = "Account not approved." });

        if (user.VolunteerFrom is not null && task.ShiftInstance.Date < user.VolunteerFrom.Value)
            return StatusCode(403, new { error = "Your volunteering period has not started yet." });

        if (user.VolunteerTo is not null && task.ShiftInstance.Date > user.VolunteerTo.Value)
            return StatusCode(403, new { error = "Your volunteering period has ended." });

        // Capacity check (optional)
        if (task.MaxVolunteers is not null)
        {
            var count = await db.TaskAssignments.CountAsync(a => a.TaskInstanceId == taskId);
            if (count >= task.MaxVolunteers.Value)
                return StatusCode(409, new { error = "Task is full." });
        }

        db.TaskAssignments.Add(
            new TaskAssignment { TaskInstanceId = taskId, VolunteerId = volunteerId }
        );

        try
        {
            await db.SaveChangesAsync();
            return Ok(new { message = "Joined task." });
        }
        catch (DbUpdateException)
        {
            // This will happen if they try to join the same task twice (unique index)
            return StatusCode(409, new { error = "Already joined this task." });
        }
    }

    // DELETE /api/shifts/{shiftId}/tasks/{taskId}/leave
    [HttpDelete("{shiftId:Guid}/tasks/{taskId:Guid}/leave")]
    public async Task<IActionResult> LeaveTask(Guid shiftId, Guid taskId)
    {
        var volunteerId = GetUserIdOrThrow();

        // Ensure task belongs to shift
        var task = await db.TaskInstances.AsNoTracking().SingleOrDefaultAsync(t => t.Id == taskId);
        if (task is null)
            return NotFound(new { error = "Task not found." });
        if (task.ShiftInstanceId != shiftId)
            return BadRequest(new { error = "Task does not belong to the shift." });

        var rows = await db
            .TaskAssignments.Where(a => a.TaskInstanceId == taskId && a.VolunteerId == volunteerId)
            .ExecuteDeleteAsync();

        if (rows == 0)
            return NotFound(new { error = "You are not assigned to this task." });
        return Ok(new { message = "Left task." });
    }

    [HttpPost("{shiftId:Guid}/tasks/{taskId:Guid}/complete")]
    public async Task<IActionResult> CompleteTask(Guid shiftId, Guid taskId)
    {
        var volunteerId = GetUserIdOrThrow();

        var task = await db
            .TaskInstances.Include(t => t.Assignments)
            .SingleOrDefaultAsync(t => t.Id == taskId);

        if (task is null)
            return NotFound(new { error = "Task not found." });

        if (task.ShiftInstanceId != shiftId)
            return BadRequest(new { error = "Task does not belong to the shift." });

        var user = await db.Users.SingleAsync(u => u.Id == volunteerId);
        var isAssigned = task.Assignments.Any(a => a.VolunteerId == volunteerId);

        if (user.Role != Role.Staff && !isAssigned)
            return StatusCode(403, new { error = "You are not assigned to this task." });

        if (task.CompletedAt is not null)
            return Conflict(new { error = "Task already completed." });

        if (task.Assignments.Count < task.RequiredVolunteers && user.Role != Role.Staff)
            return Conflict(
                new { error = "Not enough volunteers assigned to complete this task." }
            );

        task.CompletedAt = DateTime.UtcNow;
        task.CompletedByUserId = volunteerId;

        try
        {
            await db.SaveChangesAsync();
            return Ok(new { message = "Task completed." });
        }
        catch (DbUpdateConcurrencyException)
        {
            // 🔥 Someone else completed it first
            return Conflict(new { error = "Task was completed by someone else." });
        }
    }

    [HttpPost("{shiftId:Guid}/tasks/{taskId:Guid}/reopen")]
    public async Task<IActionResult> ReopenTask(Guid shiftId, Guid taskId)
    {
        var volunteerId = GetUserIdOrThrow();

        var task = await db.TaskInstances.SingleOrDefaultAsync(t => t.Id == taskId);

        if (task is null)
            return NotFound(new { error = "Task not found." });

        if (task.ShiftInstanceId != shiftId)
            return BadRequest(new { error = "Task does not belong to the shift." });

        var user = await db.Users.SingleAsync(u => u.Id == volunteerId);

        if (task.CompletedAt is null)
            return Conflict(new { error = "Task is already open." });

        if (user.Role != Role.Staff && task.CompletedByUserId != volunteerId)
            return StatusCode(403, new { error = "Only staff (or completer) can reopen." });

        task.CompletedAt = null;
        task.CompletedByUserId = null;

        try
        {
            await db.SaveChangesAsync();
            return Ok(new { message = "Task reopened." });
        }
        catch (DbUpdateConcurrencyException)
        {
            return Conflict(new { error = "Task was already reopened by someone else." });
        }
    }

    private Guid GetUserIdOrThrow()
    {
        var s = User.FindFirstValue(ClaimTypes.NameIdentifier);
        if (!Guid.TryParse(s, out var id))
            throw new UnauthorizedAccessException("Invalid token (no user id).");
        return id;
    }

    private static ShiftTaskStatus GetTaskStatus(TaskInstance task, int assignedCount)
    {
        if (task.CompletedAt is not null)
            return ShiftTaskStatus.Done;

        if (assignedCount < task.RequiredVolunteers)
            return ShiftTaskStatus.Missing;

        return ShiftTaskStatus.InProgress;
    }

    private async Task<ShiftInstance> GetOrCreateShiftInstance(DateOnly date, ShiftType type)
    {
        if (date == default)
            throw new InvalidOperationException("Invalid date.");

        if (!Enum.IsDefined(typeof(ShiftType), type))
            throw new InvalidOperationException("Invalid shift type.");

        var existing = await db
            .ShiftInstances.Include(s => s.Tasks)
            .SingleOrDefaultAsync(s => s.Date == date && s.ShiftType == type);

        if (existing is not null)
            return existing;

        var season = SeasonResolver.Resolve(date);

        var template = await db
            .ShiftTemplates.Include(t => t.Tasks)
            .SingleOrDefaultAsync(t => t.ShiftType == type && t.Season == season);

        if (template is null)
            throw new InvalidOperationException(
                $"No ShiftTemplate configured for {type} {season}."
            );

        var shift = new ShiftInstance
        {
            Date = date,
            ShiftType = type,
            Season = season,
            StartTime = template.StartTime,
            ShiftTemplateId = template.Id,
            Tasks = template
                .Tasks.Select(tt => new TaskInstance
                {
                    TaskTemplateId = tt.Id,
                    Name = tt.Name,
                    MaxVolunteers = tt.MaxVolunteers,
                    RequiredVolunteers = tt.RequiredVolunteers
                })
                .ToList()
        };

        db.ShiftInstances.Add(shift);
        await db.SaveChangesAsync();
        return shift;
    }

    private static IEnumerable<TaskInstance> FilterEveningSplitTasks(ShiftInstance shift)
    {
        var tasks = shift.Tasks.AsEnumerable();
        if (shift.ShiftType != ShiftType.Evening)
        {
            return tasks;
        }

        var baseNames = new HashSet<string>(StringComparer.OrdinalIgnoreCase);
        foreach (var task in tasks)
        {
            if (TryGetSplitBaseName(task.Name, out var baseName))
            {
                baseNames.Add(baseName);
            }
        }

        var excluded = new HashSet<string>(StringComparer.OrdinalIgnoreCase)
        {
            "Trash prep (Mon/Fri)",
            "Trash run helpers",
        };

        if (baseNames.Count == 0 && excluded.Count == 0)
        {
            return tasks;
        }

        return tasks.Where(t => !baseNames.Contains(t.Name) && !excluded.Contains(t.Name));
    }

    private static bool TryGetSplitBaseName(string name, out string baseName)
    {
        baseName = string.Empty;
        const string separator = " - ";
        var idx = name.LastIndexOf(separator, StringComparison.Ordinal);
        if (idx <= 0)
        {
            return false;
        }

        var label = name[(idx + separator.Length)..].Trim();
        if (!label.Equals("Water", StringComparison.OrdinalIgnoreCase) &&
            !label.Equals("Cleaning", StringComparison.OrdinalIgnoreCase))
        {
            return false;
        }

        baseName = name[..idx].Trim();
        return baseName.Length > 0;
    }
}
