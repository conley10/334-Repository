using Microsoft.AspNetCore.Mvc;
using SmartParking.Features.Payments.DTOs;

namespace SmartParking.Features.Payments;

[ApiController]
[Route("payments")]
public class PaymentController : ControllerBase
{
    private readonly PaymentService _paymentService;

    public PaymentController(PaymentService paymentService)
    {
        _paymentService = paymentService;
    }

    // ---------------- CREATE PAYMENT ----------------
    [HttpPost]
    public async Task<ActionResult<PaymentDto>> CreatePayment([FromBody] CreatePaymentRequest request)
    {
        var payment = await _paymentService.CreatePaymentAsync(
            request.BookingID,
            request.Amount,
            request.Method
        );

        return Ok(payment);
    }

    // ---------------- GET ALL PAYMENTS ----------------
    [HttpGet]
    public async Task<ActionResult<IEnumerable<PaymentDto>>> GetPayments()
    {
        var payments = await _paymentService.GetPaymentsAsync();
        return Ok(payments);
    }
}
