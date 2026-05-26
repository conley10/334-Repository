using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using SmartParking.Domain.Entities;

namespace SmartParking.Infrastructure.Persistence;

public class ZoneConfiguration : IEntityTypeConfiguration<Zone>
{
    public void Configure(EntityTypeBuilder<Zone> builder)
    {
        builder.HasKey(z => z.ZoneID);
        builder.Property(z => z.Name).HasMaxLength(50).IsRequired();
        builder.Property(z => z.AccessLevel).HasConversion<string>();
        builder.Property(z => z.ZoneType).HasConversion<string>();
        builder.Property(z => z.Status).HasConversion<string>().HasMaxLength(20).IsRequired();
    }
}
