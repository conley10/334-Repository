using Microsoft.AspNetCore.Authentication;
using Microsoft.EntityFrameworkCore;
using SmartParking.Domain.Common;
using SmartParking.Infrastructure.Authentication;
using SmartParking.Infrastructure.Data;
using SmartParking.Features.Auth;
using SmartParking.Features.Zones;
using SmartParking.Features.Admin;
using SmartParking.Features.Payments;
using SmartParking.Features.Violations;

var builder = WebApplication.CreateBuilder(args);

// -------------------- DATABASE --------------------
builder.Services.AddDbContext<AppDbContext>(options =>
    options.UseNpgsql(builder.Configuration.GetConnectionString("DefaultConnection"))
);

// -------------------- CONTROLLERS + SWAGGER --------------------
builder.Services.AddControllers().AddJsonOptions(options =>
{
    options.JsonSerializerOptions.PropertyNameCaseInsensitive = true;
});
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

// -------------------- FEATURE SERVICES --------------------
builder.Services.AddScoped<IZoneService, ZoneService>();
builder.Services.AddScoped<AdminService>();
builder.Services.AddScoped<PaymentService>();
builder.Services.AddScoped<ViolationService>();


// -------------------- CORS (DEV ONLY) --------------------
builder.Services.AddHttpContextAccessor();
builder.Services.AddHttpClient<MicrosoftOAuthTokenService>();

if (builder.Environment.IsDevelopment())
{
    builder.Services.AddCors(options =>
    {
        options.AddDefaultPolicy(policy =>
        {
            policy.SetIsOriginAllowed(static origin =>
                origin.StartsWith("http://localhost:", StringComparison.OrdinalIgnoreCase) ||
                origin.StartsWith("http://127.0.0.1:", StringComparison.OrdinalIgnoreCase));
            policy.AllowAnyHeader();
            policy.AllowAnyMethod();
        });
    });
}

// -------------------- AUTHENTICATION --------------------
var bypassAuth = builder.Configuration["BYPASS_AUTH"] == "true";

if (bypassAuth)
{
    builder.Services.AddScoped<ICurrentUserService, MockCurrentUserService>();
    builder
        .Services.AddAuthentication(options =>
        {
            options.DefaultAuthenticateScheme = "Mock";
            options.DefaultChallengeScheme = "Mock";
        })
        .AddScheme<AuthenticationSchemeOptions, MockAuthHandler>("Mock", null);
}
else
{
    // Real JWT config goes here later
    // builder.Services.AddScoped<ICurrentUserService, RealCurrentUserService>();
}

var app = builder.Build();

// curl/Swagger often send application/x-www-form-urlencoded; JSON endpoints need application/json.
if (app.Environment.IsDevelopment())
{
    app.Use(async (context, next) =>
    {
        if (context.Request.Method is "POST" or "PATCH" or "PUT")
            context.Request.ContentType = "application/json";

        await next();
    });
}

if (app.Environment.IsDevelopment())
{
    var cfg = app.Configuration;
    var tenant = cfg["MicrosoftAuth:TenantId"] ?? cfg["MICROSOFT_TENANT_ID"];
    var client = cfg["MicrosoftAuth:ClientId"] ?? cfg["MICROSOFT_CLIENT_ID"];
    if (string.IsNullOrWhiteSpace(tenant) || string.IsNullOrWhiteSpace(client))
    {
        app.Logger.LogWarning(
            "Microsoft OAuth not configured (missing tenant or client id). "
            + "Set MicrosoftAuth:TenantId and MicrosoftAuth:ClientId or MICROSOFT_* env vars."
        );
    }
    else
    {
        app.Logger.LogInformation("Microsoft OAuth: tenant and client id are configured.");
    }
}

// Auto-run migrations on startup
using (var scope = app.Services.CreateScope())
{
    var services = scope.ServiceProvider;
    try
    {
        var context = services.GetRequiredService<AppDbContext>();
        context.Database.Migrate();
        DbInitializer.Seed(context);
    }
    catch (Exception ex)
    {
        var logger = services.GetRequiredService<ILogger<Program>>();
        logger.LogError(ex, "An error occurred while migrating the database.");
    }
}

// -------------------- PIPELINE --------------------
if (app.Environment.IsDevelopment())
{
    app.UseDeveloperExceptionPage();
    app.UseSwagger();
    app.UseSwaggerUI();
    app.UseCors();
}

if (!app.Environment.IsDevelopment())
{
    app.UseHttpsRedirection();
}

if (bypassAuth)
{
    app.UseAuthentication();
}

if (app.Environment.IsDevelopment())
{
    app.UseCors();
}

app.UseHttpsRedirection();

app.UseAuthentication();
app.UseAuthorization();

app.MapControllers();

app.Run();
