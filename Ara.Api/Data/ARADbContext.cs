using Ara.Domain.Entities;
using Microsoft.EntityFrameworkCore;

namespace ARA.Infrastructure;

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

            e.Property(u => u.Role).HasConversion<string>().HasDefaultValue(Role.Volunteer);
            e.Property(u => u.Status)
                .HasConversion<string>()
                .HasDefaultValue(VolunteerStatus.Pending);
        });

        // ✅ Seed one Staff user (admin)
        var adminId = Guid.Parse("11111111-1111-1111-1111-111111111111");

        var admin = new User
        {
            Id = adminId,
            FirstName = "Ara",
            LastName = "Admin",
            Email = "admin@ara.local",
            PasswordHash = BCrypt.Net.BCrypt.HashPassword("Admin123!"),
            Role = Role.Staff,
            Status = VolunteerStatus.Approved,
            CreatedAt = DateTime.UtcNow
        };

        b.Entity<User>().HasData(admin);
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
