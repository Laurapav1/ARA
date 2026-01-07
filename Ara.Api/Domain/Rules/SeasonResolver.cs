using Ara.Api.Enums;

namespace Ara.Api.Shifts;

public static class SeasonResolver
{
    // Change these boundaries whenever you learn the real shelter rule.
    public static Season Resolve(DateOnly date)
    {
        // Summer: April 1 - October 31 (example)
        // Winter: November 1 - March 31
        return (date.Month >= 4 && date.Month <= 10) ? Season.Summer : Season.Winter;
    }
}
