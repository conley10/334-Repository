using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace SmartParking.Features.Payments;

[ApiController]
[Authorize]
public class PaymentsController : ControllerBase
{
    private readonly PaymentService _paymentService;

    public PaymentsController(PaymentService paymentService)
    {
        _paymentService = paymentService;
    }

    [HttpPost("payments")]
    public async Task<IActionResult> ProcessPayment([FromBody] PaymentRequest request)
    {
        if (request.Amount <= 0)
            return BadRequest(new { message = "Amount must be greater than zero" });

        var payment = await _paymentService.CreatePaymentAsync(
            request.Amount,
            request.Method,
            request.BookingID
        );

        return Ok(payment);
    }
}

public class PaymentRequest
{
    public double Amount { get; set; }
    public string Method { get; set; } = string.Empty;
    public int BookingID { get; set; }
}
