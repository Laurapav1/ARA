using Ara.Api.Enums;
using Ara.Domain.Models;
using Microsoft.EntityFrameworkCore;

namespace Ara.Api.Data;

public class ARADbContext(DbContextOptions<ARADbContext> options) : DbContext(options)
{
    public DbSet<User> Users => Set<User>();
    public DbSet<ShiftTemplate> ShiftTemplates => Set<ShiftTemplate>();
    public DbSet<TaskTemplate> TaskTemplates => Set<TaskTemplate>();
    public DbSet<ShiftInstance> ShiftInstances => Set<ShiftInstance>();
    public DbSet<TaskInstance> TaskInstances => Set<TaskInstance>();
    public DbSet<TaskAssignment> TaskAssignments => Set<TaskAssignment>();
    public DbSet<Animal> Animals => Set<Animal>();

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

            e.Property(u => u.RefreshTokenHash).HasMaxLength(200);
            e.Property(u => u.RefreshTokenCreatedAt).IsRequired(false);
            e.Property(u => u.RefreshTokenExpiresAt).IsRequired(false);
            e.Property(u => u.RefreshTokenRevokedAt).IsRequired(false);
        });

        b.Entity<ShiftTemplate>(e =>
        {
            e.HasKey(x => x.Id);

            // If ShiftType/Season are enums, this stores them as strings (nice in Postgres)
            e.Property(x => x.ShiftType).HasConversion<string>().IsRequired();
            e.Property(x => x.Season).HasConversion<string>().IsRequired();

            e.Property(x => x.StartTime).IsRequired();
            e.Property(x => x.Title).HasMaxLength(200);

            e.HasMany(x => x.Tasks)
                .WithOne(x => x.ShiftTemplate)
                .HasForeignKey(x => x.ShiftTemplateId)
                .OnDelete(DeleteBehavior.Cascade);

            // Prevent duplicate templates (morning+winter twice, etc.)
            e.HasIndex(x => new { x.ShiftType, x.Season }).IsUnique();
        });

        b.Entity<TaskTemplate>(e =>
        {
            e.HasKey(x => x.Id);

            e.Property(x => x.Name).IsRequired().HasMaxLength(200);
            e.Property(x => x.MaxVolunteers).IsRequired(false);
        });

        b.Entity<ShiftInstance>(e =>
        {
            e.HasKey(x => x.Id);

            e.Property(x => x.Date).IsRequired();
            e.Property(x => x.ShiftType).HasConversion<string>().IsRequired();
            e.Property(x => x.Season).HasConversion<string>().IsRequired();
            e.Property(x => x.StartTime).IsRequired();

            // One morning + one evening per date
            e.HasIndex(x => new { x.Date, x.ShiftType }).IsUnique();

            e.HasMany(x => x.Tasks)
                .WithOne(x => x.ShiftInstance)
                .HasForeignKey(x => x.ShiftInstanceId)
                .OnDelete(DeleteBehavior.Cascade);
        });

        b.Entity<TaskInstance>(e =>
        {
            e.HasKey(x => x.Id);

            e.Property(x => x.Name).IsRequired().HasMaxLength(200);
            e.Property(x => x.MaxVolunteers).IsRequired(false);

            e.HasMany(x => x.Assignments)
                .WithOne(x => x.TaskInstance)
                .HasForeignKey(x => x.TaskInstanceId)
                .OnDelete(DeleteBehavior.Cascade);
        });

        b.Entity<TaskAssignment>(e =>
        {
            e.HasKey(x => x.Id);

            e.Property(x => x.CreatedAt).IsRequired();

            // prevent joining same task twice (same day implied by TaskInstance)
            e.HasIndex(x => new { x.TaskInstanceId, x.VolunteerId }).IsUnique();

            e.HasOne(x => x.Volunteer)
                .WithMany() // you can add navigation User.Assignments later if you want
                .HasForeignKey(x => x.VolunteerId)
                .OnDelete(DeleteBehavior.Restrict);
        });

        b.Entity<Animal>(e =>
        {
            e.HasKey(x => x.Id);

            e.Property(x => x.Name).IsRequired().HasMaxLength(200);
            e.Property(x => x.Species).HasConversion<string>().IsRequired();
            e.Property(x => x.Gender).HasConversion<string>().IsRequired();
            e.Property(x => x.HandlingLevel).HasConversion<string>().IsRequired();
            e.Property(x => x.HandlingFlags);
            e.Property(x => x.AnimalStatus).HasConversion<string>().IsRequired();
            e.Property(x => x.DogZone).HasConversion<string>().IsRequired(false);
            e.Property(x => x.CatZone).HasConversion<string>().IsRequired(false);
            e.Property(x => x.Picture).HasMaxLength(500);
            e.Property(x => x.Breed).HasMaxLength(200);
            e.Property(x => x.History).HasMaxLength(500);
            e.Property(x => x.RequiresCare).IsRequired();
            e.Property(x => x.InTreatment).IsRequired();
            e.Ignore(x => x.TrainingLinks);
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
