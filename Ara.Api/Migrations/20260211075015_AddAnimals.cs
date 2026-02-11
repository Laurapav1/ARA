using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Ara.Api.Migrations
{
    /// <inheritdoc />
    public partial class AddAnimals : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "Animals",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uuid", nullable: false),
                    Name = table.Column<string>(type: "character varying(200)", maxLength: 200, nullable: false),
                    Species = table.Column<string>(type: "text", nullable: false),
                    Gender = table.Column<string>(type: "text", nullable: false),
                    CatZone = table.Column<string>(type: "text", nullable: false),
                    DogZone = table.Column<string>(type: "text", nullable: false),
                    HandlingLevel = table.Column<string>(type: "text", nullable: false),
                    Picture = table.Column<string>(type: "character varying(500)", maxLength: 500, nullable: true),
                    HandlingNotes = table.Column<string>(type: "text", nullable: true),
                    Age = table.Column<int>(type: "integer", nullable: true),
                    Breed = table.Column<string>(type: "character varying(200)", maxLength: 200, nullable: true),
                    History = table.Column<string>(type: "character varying(500)", maxLength: 500, nullable: true),
                    HandlingFlags = table.Column<int>(type: "integer", nullable: false),
                    AnimalStatus = table.Column<string>(type: "text", nullable: false),
                    RequiresCare = table.Column<bool>(type: "boolean", nullable: false),
                    InTreatment = table.Column<bool>(type: "boolean", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Animals", x => x.Id);
                });
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "Animals");
        }
    }
}
