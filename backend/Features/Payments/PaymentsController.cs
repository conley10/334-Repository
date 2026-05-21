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

    [HttpPost]
    public async Task<IActionResult> CreatePayment([FromBody] CreatePaymentRequest request)
    {
        // 1. Placeholder for JWT authentication
        bool userAuthenticated = true; // Replace with real JWT later

        if (!userAuthenticated)
        {
            return Unauthorized(new
            {
                error = "unauthorized",
                message = "You must be logged in to make a payment"
            });
        }

        // 2. Process payment
        var result = await _paymentService.CreatePaymentAsync(
            request.BookingID,
            request.Amount,
            request.Method
        );

        // 3. 402 Payment Declined
        if (result.StatusCode == 402)
        {
            return StatusCode(402, new
            {
                error = "payment_declined",
                message = result.Error
            });
        }

        // 4. 400 Bad Request (validation / business rules)
        if (!result.Success)
        {
            return BadRequest(new
            {
                error = "payment_error",
                message = result.Error
            });
        }

        // 5. 200 OK
        return Ok(result.Data);
    }
}
