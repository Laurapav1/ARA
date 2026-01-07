using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Ara.Api.Migrations
{
    /// <inheritdoc />
    public partial class AddTaskInstanceRowVersion : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<int>(
                name: "RequiredVolunteers",
                table: "TaskTemplates",
                type: "integer",
                nullable: false,
                defaultValue: 0);

            migrationBuilder.AddColumn<DateTime>(
                name: "CompletedAt",
                table: "TaskInstances",
                type: "timestamp with time zone",
                nullable: true);

            migrationBuilder.AddColumn<Guid>(
                name: "CompletedByUserId",
                table: "TaskInstances",
                type: "uuid",
                nullable: true);

            migrationBuilder.AddColumn<int>(
                name: "RequiredVolunteers",
                table: "TaskInstances",
                type: "integer",
                nullable: false,
                defaultValue: 0);

            migrationBuilder.AddColumn<byte[]>(
                name: "RowVersion",
                table: "TaskInstances",
                type: "bytea",
                rowVersion: true,
                nullable: false,
                defaultValue: new byte[0]);

            migrationBuilder.CreateIndex(
                name: "IX_TaskInstances_CompletedByUserId",
                table: "TaskInstances",
                column: "CompletedByUserId");

            migrationBuilder.AddForeignKey(
                name: "FK_TaskInstances_Users_CompletedByUserId",
                table: "TaskInstances",
                column: "CompletedByUserId",
                principalTable: "Users",
                principalColumn: "Id");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_TaskInstances_Users_CompletedByUserId",
                table: "TaskInstances");

            migrationBuilder.DropIndex(
                name: "IX_TaskInstances_CompletedByUserId",
                table: "TaskInstances");

            migrationBuilder.DropColumn(
                name: "RequiredVolunteers",
                table: "TaskTemplates");

            migrationBuilder.DropColumn(
                name: "CompletedAt",
                table: "TaskInstances");

            migrationBuilder.DropColumn(
                name: "CompletedByUserId",
                table: "TaskInstances");

            migrationBuilder.DropColumn(
                name: "RequiredVolunteers",
                table: "TaskInstances");

            migrationBuilder.DropColumn(
                name: "RowVersion",
                table: "TaskInstances");
        }
    }
}
