namespace SmartParking.Infrastructure.Authentication;

/// Shared identity for BYPASS_AUTH mock mode (matches John Student from DbInitializer).
public static class MockAuthDefaults
{
    public const int UserId = 2;
    public const string Name = "John Student";
    public const string Email = "john@student.edu";

    /// Extra roles so Admin-, Student-, and Staff-gated endpoints are testable without a real JWT.
    public static readonly string[] Roles = ["Admin", "Student", "Staff"];
}
