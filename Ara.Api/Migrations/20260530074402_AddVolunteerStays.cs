using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Ara.Api.Migrations
{
    /// <inheritdoc />
    public partial class AddVolunteerStays : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "VolunteerStays",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uuid", nullable: false),
                    UserId = table.Column<Guid>(type: "uuid", nullable: false),
                    Status = table.Column<string>(type: "text", nullable: false, defaultValue: "Pending"),
                    VolunteerFrom = table.Column<DateOnly>(type: "date", nullable: false),
                    VolunteerTo = table.Column<DateOnly>(type: "date", nullable: false),
                    RequestedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    ApprovedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: true),
                    ApprovedByUserId = table.Column<Guid>(type: "uuid", nullable: true),
                    CancelledAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_VolunteerStays", x => x.Id);
                    table.ForeignKey(
                        name: "FK_VolunteerStays_Users_UserId",
                        column: x => x.UserId,
                        principalTable: "Users",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateIndex(
                name: "IX_VolunteerStays_UserId_Status_VolunteerFrom_VolunteerTo",
                table: "VolunteerStays",
                columns: new[] { "UserId", "Status", "VolunteerFrom", "VolunteerTo" });

            migrationBuilder.Sql(@"CREATE EXTENSION IF NOT EXISTS pgcrypto;");
            migrationBuilder.Sql(
                @"
INSERT INTO ""VolunteerStays"" (
    ""Id"",
    ""UserId"",
    ""Status"",
    ""VolunteerFrom"",
    ""VolunteerTo"",
    ""RequestedAt"",
    ""ApprovedAt"",
    ""ApprovedByUserId"",
    ""CancelledAt""
)
SELECT
    gen_random_uuid(),
    ""Id"",
    CASE
        WHEN ""Status"" = 'Approved' THEN 'Approved'
        WHEN ""Status"" = 'Declined' THEN 'Declined'
        ELSE 'Pending'
    END,
    ""VolunteerFrom"",
    ""VolunteerTo"",
    ""CreatedAt"",
    CASE WHEN ""Status"" = 'Approved' THEN COALESCE(""UpdatedAt"", ""CreatedAt"") ELSE NULL END,
    NULL,
    NULL
FROM ""Users""
WHERE ""Role"" = 'Volunteer'
  AND ""VolunteerFrom"" IS NOT NULL
  AND ""VolunteerTo"" IS NOT NULL;
"
            );
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "VolunteerStays");
        }
    }
}
