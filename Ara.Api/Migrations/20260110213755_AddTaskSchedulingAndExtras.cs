using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Ara.Api.Migrations
{
    /// <inheritdoc />
    public partial class AddTaskSchedulingAndExtras : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_TaskInstances_TaskTemplates_TaskTemplateId",
                table: "TaskInstances"
            );

            migrationBuilder.AddColumn<string>(
                name: "Category",
                table: "TaskTemplates",
                type: "text",
                nullable: false,
                defaultValue: ""
            );

            migrationBuilder.AddColumn<int>(
                name: "DaysOfWeekMask",
                table: "TaskTemplates",
                type: "integer",
                nullable: true
            );

            migrationBuilder.AlterColumn<Guid>(
                name: "TaskTemplateId",
                table: "TaskInstances",
                type: "uuid",
                nullable: true,
                oldClrType: typeof(Guid),
                oldType: "uuid"
            );

            migrationBuilder.AddColumn<string>(
                name: "Category",
                table: "TaskInstances",
                type: "text",
                nullable: false,
                defaultValue: ""
            );

            migrationBuilder.AddColumn<bool>(
                name: "IsExtra",
                table: "TaskInstances",
                type: "boolean",
                nullable: false,
                defaultValue: false
            );

            migrationBuilder.AddColumn<TimeOnly>(
                name: "StartTime",
                table: "TaskInstances",
                type: "time without time zone",
                nullable: true
            );

            migrationBuilder.AddForeignKey(
                name: "FK_TaskInstances_TaskTemplates_TaskTemplateId",
                table: "TaskInstances",
                column: "TaskTemplateId",
                principalTable: "TaskTemplates",
                principalColumn: "Id",
                onDelete: ReferentialAction.SetNull
            );
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_TaskInstances_TaskTemplates_TaskTemplateId",
                table: "TaskInstances"
            );

            migrationBuilder.DropColumn(name: "Category", table: "TaskTemplates");

            migrationBuilder.DropColumn(name: "DaysOfWeekMask", table: "TaskTemplates");

            migrationBuilder.DropColumn(name: "Category", table: "TaskInstances");

            migrationBuilder.DropColumn(name: "IsExtra", table: "TaskInstances");

            migrationBuilder.DropColumn(name: "StartTime", table: "TaskInstances");

            migrationBuilder.AlterColumn<Guid>(
                name: "TaskTemplateId",
                table: "TaskInstances",
                type: "uuid",
                nullable: false,
                defaultValue: new Guid("00000000-0000-0000-0000-000000000000"),
                oldClrType: typeof(Guid),
                oldType: "uuid",
                oldNullable: true
            );

            migrationBuilder.AddForeignKey(
                name: "FK_TaskInstances_TaskTemplates_TaskTemplateId",
                table: "TaskInstances",
                column: "TaskTemplateId",
                principalTable: "TaskTemplates",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade
            );
        }
    }
}
