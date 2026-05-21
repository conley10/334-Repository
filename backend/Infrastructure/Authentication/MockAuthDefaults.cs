namespace SmartParking.Infrastructure.Authentication;

/// <summary>
/// Shared identity for <c>BYPASS_AUTH</c> mock mode (matches John Student in DbInitializer seed data).
/// </summary>
public static class MockAuthDefaults
{
    public const string SchemeName = "Mock";

    public const int UserId = 2;
    public const string Name = "John Student";
    public const string Email = "john@student.edu";

    /// <summary>All roles so Admin-, Student-, and Staff-gated endpoints are testable without a real JWT.</summary>
    public static readonly string[] Roles = ["Admin", "Student", "Staff"];
}
