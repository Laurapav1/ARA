using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Design;

namespace Ara.Api.Data;

public class ARADbContextFactory : IDesignTimeDbContextFactory<ARADbContext>
{
    public ARADbContext CreateDbContext(string[] args)
    {
        var cs =
            Environment.GetEnvironmentVariable("ConnectionStrings__Postgres")
            ?? "Host=localhost;Port=5432;Database=ara_db;Username=ara_user;Password=supersecret";

        var options = new DbContextOptionsBuilder<ARADbContext>().UseNpgsql(cs).Options;

        return new ARADbContext(options);
    }
}
