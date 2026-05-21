using SmartParking.Domain.Entities;
using SmartParking.Domain.Enums;
using SmartParking.Infrastructure.Data;

namespace SmartParking.Features.Payments;

public class PaymentService
{
    private readonly AppDbContext _db;

    public PaymentService(AppDbContext db)
    {
        _db = db;
    }

    public async Task<Payment> CreatePaymentAsync(double amount, string method, int bookingId)
    {
        var payment = new Payment
        {
            Amount = amount,
            Method = method,
            BookingID = bookingId,
            Status = PaymentStatus.Paid,
            PaidAt = DateTime.UtcNow
        };

        _db.Payments.Add(payment);
        await _db.SaveChangesAsync();

        return payment;
    }
}
