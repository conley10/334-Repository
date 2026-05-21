using Microsoft.AspNetCore.Authentication;
using Microsoft.EntityFrameworkCore;
using SmartParking.Domain.Common;
using SmartParking.Infrastructure.Authentication;
using SmartParking.Infrastructure.Data;

// Feature services
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
builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

// -------------------- FEATURE SERVICES --------------------
builder.Services.AddScoped<IZoneService, ZoneService>();
builder.Services.AddScoped<AdminService>();
builder.Services.AddScoped<PaymentService>();
builder.Services.AddScoped<ViolationService>();
builder.Services.AddScoped<PaymentService>();


// -------------------- CORS (DEV ONLY) --------------------
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
    // Mock Identity & Auth
    builder.Services.AddScoped<ICurrentUserService, MockCurrentUserService>();
    builder.Services.AddAuthentication("Mock")
        .AddScheme<AuthenticationSchemeOptions, MockAuthHandler>("Mock", null);
}
else
{
    // Real JWT config goes here later
    // builder.Services.AddScoped<ICurrentUserService, RealCurrentUserService>();
}

var app = builder.Build();

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
