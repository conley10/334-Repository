namespace SmartParking.Features.Payments.DTOs;

public class CreatePaymentRequest
{
    public int BookingID { get; set; }
    public double Amount { get; set; }
    public string Method { get; set; } = string.Empty;
}
