using Ara.Api.Data;
using Ara.Api.Enums;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace Ara.Api.Controllers;

[Route("api/[controller]")]
[ApiController]
public class VolunteersController(ARADbContext db) : ControllerBase
{
    // Get /api/volunteers/pending
    [HttpGet("pending")]
    [Authorize(Roles = "Staff")]
    public async Task<IActionResult> GetPendingVolunteers()
    {
        var pendingVolunteers = await db
            .Users.Where(u => u.Role == Role.Volunteer && u.Status == VolunteerStatus.Pending)
            .Select(u => new
            {
                u.Id,
                u.FirstName,
                u.LastName,
                u.Email,
                u.CreatedAt
            })
            .ToListAsync();

        return Ok(pendingVolunteers);
    }

    [HttpPut("{id:Guid}/approve")]
    [Authorize(Roles = "Staff")]
    public async Task<IActionResult> ApproveVolunteer(Guid id)
    {
        var rows = await db
            .Users.Where(u => u.Id == id && u.Role == Role.Volunteer)
            .ExecuteUpdateAsync(s => s.SetProperty(u => u.Status, VolunteerStatus.Approved));

        if (rows == 0)
            return NotFound(new { error = "Volunteer not found" });
        return Ok(new { message = "Volunteer approved" });
    }

    // PUT /api/volunteers/{id}/decline
    [HttpPut("{id:Guid}/decline")]
    [Authorize(Roles = "Staff")]
    public async Task<IActionResult> DeclineVolunteer(Guid id)
    {
        var rows = await db
            .Users.Where(u => u.Id == id && u.Role == Role.Volunteer)
            .ExecuteUpdateAsync(s => s.SetProperty(u => u.Status, VolunteerStatus.Declined));

        if (rows == 0)
            return NotFound(new { error = "Volunteer not found" });
        return Ok(new { message = "Volunteer declined" });
    }

    // GET /api/volunteers?status=pending|approved|declined
    [HttpGet]
    public async Task<IActionResult> ListVolunteers([FromQuery] VolunteerStatus? status = null)
    {
        var q = db.Users.Where(u => u.Role == Role.Volunteer);
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
}
