using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Ara.Api.Migrations
{
    /// <inheritdoc />
    public partial class RemoveUserStayDates : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "VolunteerFrom",
                table: "Users");

            migrationBuilder.DropColumn(
                name: "VolunteerTo",
                table: "Users");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<DateOnly>(
                name: "VolunteerFrom",
                table: "Users",
                type: "date",
                nullable: true);

            migrationBuilder.AddColumn<DateOnly>(
                name: "VolunteerTo",
                table: "Users",
                type: "date",
                nullable: true);
        }
    }
}
