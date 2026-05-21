using Microsoft.AspNetCore.Authentication;
using Microsoft.EntityFrameworkCore;
using SmartParking.Domain.Common;
using SmartParking.Infrastructure.Authentication;
using SmartParking.Infrastructure.Data;
using SmartParking.Features.Zones;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
builder.Services.AddDbContext<AppDbContext>(options =>
    options.UseNpgsql(builder.Configuration.GetConnectionString("DefaultConnection"))
);

builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();
builder.Services.AddScoped<IZoneService, ZoneService>();


// --- Master Switch Security ---
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
    // The "Real" JWT config will go here later
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

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseDeveloperExceptionPage();
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseHttpsRedirection();
app.UseAuthorization();

app.MapControllers();

app.Run();
