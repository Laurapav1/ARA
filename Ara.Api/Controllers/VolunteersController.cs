using System.Security.Claims;
using Ara.Api.Data;
using Ara.Api.Dtos;
using Ara.Api.Enums;
using Ara.Domain.Models;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace Ara.Api.Controllers;

[Route("api/[controller]")]
[ApiController]
public class VolunteersController(ARADbContext db) : ControllerBase
{
    [HttpGet("stays")]
    [Authorize(Roles = "Staff")]
    public async Task<IActionResult> GetVolunteerStays()
    {
        var stays = await db
            .VolunteerStays.AsNoTracking()
            .Include(s => s.User)
            .Where(s =>
                s.User.Role == Role.Volunteer
                && (s.Status == VolunteerStayStatus.Pending || s.Status == VolunteerStayStatus.Approved)
            )
            .OrderBy(s => s.Status)
            .ThenBy(s => s.VolunteerFrom)
            .ThenBy(s => s.RequestedAt)
            .ToListAsync();

        return Ok(await BuildStayResponses(stays));
    }

    [HttpGet("pending")]
    [Authorize(Roles = "Staff")]
    public async Task<IActionResult> GetPendingVolunteers()
    {
        var stays = await db
            .VolunteerStays.AsNoTracking()
            .Include(s => s.User)
            .Where(s => s.User.Role == Role.Volunteer && s.Status == VolunteerStayStatus.Pending)
            .OrderBy(s => s.VolunteerFrom)
            .ThenBy(s => s.RequestedAt)
            .ToListAsync();

        return Ok(await BuildStayResponses(stays));
    }

    [HttpGet("me/stays")]
    [Authorize(Roles = "Volunteer")]
    public async Task<ActionResult<List<MyVolunteerStayResponse>>> GetMyStays()
    {
        var userId = GetUserIdOrThrow();
        var stays = await db
            .VolunteerStays.AsNoTracking()
            .Where(s => s.UserId == userId)
            .OrderByDescending(s => s.VolunteerFrom)
            .Select(s => new MyVolunteerStayResponse(
                s.Id,
                s.Status.ToString().ToLowerInvariant(),
                s.VolunteerFrom,
                s.VolunteerTo,
                s.RequestedAt
            ))
            .ToListAsync();

        return Ok(stays);
    }

    [HttpPost("me/stays")]
    [Authorize(Roles = "Volunteer")]
    public async Task<IActionResult> RequestNewStay([FromBody] CreateVolunteerStayRequest request)
    {
        if (request.VolunteerTo < request.VolunteerFrom)
        {
            return BadRequest(new { error = "VolunteerTo must be on or after VolunteerFrom" });
        }

        var userId = GetUserIdOrThrow();
        var user = await db.Users.SingleOrDefaultAsync(u => u.Id == userId && u.Role == Role.Volunteer);
        if (user is null)
        {
            return Unauthorized(new { error = "Volunteer not found." });
        }

        if (await HasOverlappingPendingOrApprovedStay(userId, request.VolunteerFrom, request.VolunteerTo))
        {
            return Conflict(new { error = "You already have a pending or approved stay for those dates." });
        }

        var stay = new VolunteerStay
        {
            UserId = userId,
            Status = VolunteerStayStatus.Pending,
            VolunteerFrom = request.VolunteerFrom,
            VolunteerTo = request.VolunteerTo,
            RequestedAt = DateTime.UtcNow
        };

        db.VolunteerStays.Add(stay);
        await db.SaveChangesAsync();

        return Created(
            string.Empty,
            new
            {
                message = "Stay request submitted",
                id = stay.Id
            }
        );
    }

    [HttpPut("{id:Guid}/approve")]
    [Authorize(Roles = "Staff")]
    public async Task<IActionResult> ApproveVolunteer(Guid id)
    {
        var staffId = GetUserIdOrThrow();
        var stay = await db
            .VolunteerStays.Include(s => s.User)
            .SingleOrDefaultAsync(s => s.Id == id && s.User.Role == Role.Volunteer);

        if (stay is null)
            return NotFound(new { error = "Volunteer stay not found" });

        stay.Status = VolunteerStayStatus.Approved;
        stay.ApprovedAt = DateTime.UtcNow;
        stay.ApprovedByUserId = staffId;
        stay.CancelledAt = null;
        stay.User.Status = VolunteerStatus.Approved;
        stay.User.VolunteerFrom = stay.VolunteerFrom;
        stay.User.VolunteerTo = stay.VolunteerTo;

        await db.SaveChangesAsync();
        return Ok(new { message = "Volunteer stay approved" });
    }

    [HttpPut("{id:Guid}/decline")]
    [Authorize(Roles = "Staff")]
    public async Task<IActionResult> DeclineVolunteer(Guid id)
    {
        var stay = await db
            .VolunteerStays.Include(s => s.User)
            .SingleOrDefaultAsync(s => s.Id == id && s.User.Role == Role.Volunteer);

        if (stay is null)
            return NotFound(new { error = "Volunteer stay not found" });

        stay.Status = VolunteerStayStatus.Declined;

        var hasApprovedStay = await db.VolunteerStays.AnyAsync(s =>
            s.UserId == stay.UserId && s.Id != stay.Id && s.Status == VolunteerStayStatus.Approved
        );
        if (!hasApprovedStay)
        {
            stay.User.Status = VolunteerStatus.Declined;
            stay.User.VolunteerFrom = null;
            stay.User.VolunteerTo = null;
        }

        await db.SaveChangesAsync();
        return Ok(new { message = "Volunteer stay declined" });
    }

    [HttpPut("{id:Guid}/stay")]
    [Authorize(Roles = "Staff")]
    public async Task<IActionResult> UpdateVolunteerStay(
        Guid id,
        [FromBody] UpdateVolunteerStayRequest request
    )
    {
        if (request.VolunteerTo < request.VolunteerFrom)
        {
            return BadRequest(new { error = "VolunteerTo must be on or after VolunteerFrom" });
        }

        var stay = await db
            .VolunteerStays.Include(s => s.User)
            .SingleOrDefaultAsync(s => s.Id == id && s.User.Role == Role.Volunteer);
        if (stay is null)
        {
            return NotFound(new { error = "Volunteer stay not found" });
        }

        if (stay.Status != VolunteerStayStatus.Approved)
        {
            return BadRequest(
                new { error = "Only approved volunteer stays can have dates updated" }
            );
        }

        if (await HasOverlappingPendingOrApprovedStay(stay.UserId, request.VolunteerFrom, request.VolunteerTo, stay.Id))
        {
            return Conflict(new { error = "This volunteer already has another pending or approved stay for those dates." });
        }

        stay.VolunteerFrom = request.VolunteerFrom;
        stay.VolunteerTo = request.VolunteerTo;
        stay.User.VolunteerFrom = request.VolunteerFrom;
        stay.User.VolunteerTo = request.VolunteerTo;
        await db.SaveChangesAsync();

        return Ok(new { message = "Volunteer stay updated" });
    }

    [HttpPut("{id:Guid}/cancel")]
    [Authorize(Roles = "Staff")]
    public async Task<IActionResult> CancelVolunteerStay(Guid id)
    {
        var stay = await db
            .VolunteerStays.Include(s => s.User)
            .SingleOrDefaultAsync(s =>
                s.Id == id && s.User.Role == Role.Volunteer && s.Status == VolunteerStayStatus.Approved
            );

        if (stay is null)
        {
            return NotFound(new { error = "Approved volunteer stay not found" });
        }

        stay.Status = VolunteerStayStatus.Cancelled;
        stay.CancelledAt = DateTime.UtcNow;

        var nextApprovedStay = await db
            .VolunteerStays.Where(s =>
                s.UserId == stay.UserId
                && s.Id != stay.Id
                && s.Status == VolunteerStayStatus.Approved
            )
            .OrderByDescending(s => s.VolunteerTo)
            .FirstOrDefaultAsync();

        if (nextApprovedStay is null)
        {
            stay.User.VolunteerFrom = null;
            stay.User.VolunteerTo = null;
        }
        else
        {
            stay.User.VolunteerFrom = nextApprovedStay.VolunteerFrom;
            stay.User.VolunteerTo = nextApprovedStay.VolunteerTo;
        }

        await db.SaveChangesAsync();
        return Ok(new { message = "Volunteer stay cancelled" });
    }

    [HttpGet]
    [Authorize(Roles = "Staff")]
    public async Task<IActionResult> ListVolunteers([FromQuery] VolunteerStatus? status = null)
    {
        var q = db.Users.AsNoTracking().Where(u => u.Role == Role.Volunteer);
        if (status is not null)
            q = q.Where(u => u.Status == status);

        var list = await q.OrderBy(u => u.CreatedAt)
            .Select(u => new
            {
                u.Id,
                u.FirstName,
                u.LastName,
                u.Email,
                status = u.Status.ToString().ToLowerInvariant(),
                u.CreatedAt
            })
            .ToListAsync();

        return Ok(list);
    }

    private Guid GetUserIdOrThrow()
    {
        var s = User.FindFirstValue(ClaimTypes.NameIdentifier);
        if (!Guid.TryParse(s, out var id))
            throw new UnauthorizedAccessException("Invalid token (no user id).");
        return id;
    }

    private async Task<bool> HasOverlappingPendingOrApprovedStay(
        Guid userId,
        DateOnly volunteerFrom,
        DateOnly volunteerTo,
        Guid? excludedStayId = null
    )
    {
        return await db.VolunteerStays.AnyAsync(s =>
            s.UserId == userId
            && s.Id != excludedStayId
            && (s.Status == VolunteerStayStatus.Pending || s.Status == VolunteerStayStatus.Approved)
            && volunteerFrom <= s.VolunteerTo
            && volunteerTo >= s.VolunteerFrom
        );
    }

    private async Task<List<VolunteerStayResponse>> BuildStayResponses(List<VolunteerStay> stays)
    {
        var userIds = stays.Select(s => s.UserId).Distinct().ToList();
        var previousApprovedStays = await db
            .VolunteerStays.AsNoTracking()
            .Where(s => userIds.Contains(s.UserId) && s.Status == VolunteerStayStatus.Approved)
            .OrderByDescending(s => s.VolunteerTo)
            .ToListAsync();

        return stays
            .Select(stay =>
            {
                var previous = previousApprovedStays
                    .Where(s => s.UserId == stay.UserId && s.VolunteerTo < stay.VolunteerFrom)
                    .OrderByDescending(s => s.VolunteerTo)
                    .ToList();
                var lastStay = previous.FirstOrDefault();

                return new VolunteerStayResponse(
                    stay.Id,
                    stay.UserId,
                    stay.User.FirstName,
                    stay.User.LastName,
                    stay.User.Email,
                    stay.Status.ToString().ToLowerInvariant(),
                    stay.RequestedAt,
                    stay.VolunteerFrom,
                    stay.VolunteerTo,
                    previous.Count > 0,
                    previous.Count,
                    lastStay?.VolunteerFrom,
                    lastStay?.VolunteerTo
                );
            })
            .ToList();
    }
}
