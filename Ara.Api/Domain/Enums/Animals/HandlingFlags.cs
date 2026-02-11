namespace Ara.Api.Enums;

[Flags]
public enum HandlingFlags
{
    None = 0,
    DoubleLeash = 1 << 0,
    Muzzle = 1 << 1,
    ExperiencedHandler = 1 << 2,
    NoPark = 1 << 3,
    Quarantine = 1 << 4
}
