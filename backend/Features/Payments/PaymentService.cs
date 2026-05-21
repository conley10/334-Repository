using Microsoft.EntityFrameworkCore;
using SmartParking.Domain.Entities;
using SmartParking.Domain.Enums;
using SmartParking.Features.Payments.DTOs;
using SmartParking.Infrastructure.Data;

namespace SmartParking.Features.Payments;

public class PaymentService
{
    private readonly AppDbContext _db;

    public PaymentService(AppDbContext db)
    {
        _db = db;
    }

    // ---------------- CREATE PAYMENT ----------------
    public async Task<PaymentDto> CreatePaymentAsync(int bookingId, double amount, string method)
    {
        // 1. Validate booking exists
        var booking = await _db.Bookings.FindAsync(bookingId);
        if (booking == null)
            throw new Exception("Booking not found");

        // 2. Create payment
        var payment = new Payment
        {
            BookingID = bookingId,
            Amount = amount,
            Method = method,
            Status = PaymentStatus.Paid,   // <-- FIXED HERE
            PaidAt = DateTime.UtcNow
        };

        // 3. Save to DB
        _db.Payments.Add(payment);
        await _db.SaveChangesAsync();

        // 4. Return DTO
        return new PaymentDto(
            payment.PaymentID,
            payment.Amount,
            payment.Method,
            payment.Status.ToString().ToLower(),
            payment.PaidAt,
            payment.BookingID
        );
    }

    // ---------------- GET ALL PAYMENTS ----------------
    public async Task<List<PaymentDto>> GetPaymentsAsync()
    {
        return await _db.Payments
            .Select(p => new PaymentDto(
                p.PaymentID,
                p.Amount,
                p.Method,
                p.Status.ToString().ToLower(),
                p.PaidAt,
                p.BookingID
            ))
            .ToListAsync();
    }
}
