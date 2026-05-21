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

    // Returns: Success, ErrorMessage, StatusCode, Data
    public async Task<(bool Success, string Error, int StatusCode, PaymentDto? Data)> CreatePaymentAsync(
        int bookingId, double amount, string method)
    {
        // 1. Validate booking exists
        var booking = await _db.Bookings.FindAsync(bookingId);
        if (booking == null)
            return (false, "Booking not found", 400, null);

        // 2. Check if payment already exists for this booking
        var existingPayment = await _db.Payments
            .FirstOrDefaultAsync(p => p.BookingID == bookingId);

        if (existingPayment != null)
            return (false, "Payment has already been made for this booking", 400, null);

        // 3. Simulate payment decline (example rule)
        if (method.ToLower() == "card" && amount > 500)
            return (false, "Card was declined by payment gateway", 402, null);

        // 4. Create payment
        var payment = new Payment
        {
            BookingID = bookingId,
            Amount = amount,
            Method = method,
            Status = PaymentStatus.Paid,
            PaidAt = DateTime.UtcNow
        };

        _db.Payments.Add(payment);
        await _db.SaveChangesAsync();

        var dto = new PaymentDto(
            payment.PaymentID,
            payment.Amount,
            payment.Method,
            payment.Status.ToString().ToLower(),
            payment.PaidAt,
            payment.BookingID
        );

        return (true, "", 200, dto);
    }
}
