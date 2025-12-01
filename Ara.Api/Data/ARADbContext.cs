using Ara.Api.Enums;
using Ara.Domain.Models;
using Microsoft.EntityFrameworkCore;

namespace Ara.Api.Data;

public class ARADbContext(DbContextOptions<ARADbContext> options) : DbContext(options)
{
    public DbSet<User> Users => Set<User>();

    protected override void OnModelCreating(ModelBuilder b)
    {
        base.OnModelCreating(b);

        b.Entity<User>(e =>
        {
            e.HasKey(u => u.Id);

            e.Property(u => u.FirstName).IsRequired();

            e.Property(u => u.LastName).IsRequired();

            e.Property(u => u.Email).IsRequired();

            e.HasIndex(u => u.Email).IsUnique();

            e.Property(u => u.PasswordHash).IsRequired();

            // store enums as strings, with defaults
            e.Property(u => u.Role).HasConversion<string>().HasDefaultValue(Role.Volunteer);

            e.Property(u => u.Status)
                .HasConversion<string>()
                .HasDefaultValue(VolunteerStatus.Pending);

            e.Property(u => u.CreatedAt);

            e.Property(u => u.UpdatedAt).IsRequired(false);
        });
    }

    public override Task<int> SaveChangesAsync(CancellationToken ct = default)
    {
        foreach (var entry in ChangeTracker.Entries<User>())
        {
            if (entry.State == EntityState.Modified)
                entry.Entity.UpdatedAt = DateTime.UtcNow;
        }

        return base.SaveChangesAsync(ct);
    }
}
