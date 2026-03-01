using System.Text.Json;

namespace Ara.Api.Dtos.Information;

public record InformationBlobDto(string Key, JsonElement Data, DateTime UpdatedAt);

public record UpsertInformationBlobRequest(JsonElement Data);
