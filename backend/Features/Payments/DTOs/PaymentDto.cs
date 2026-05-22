namespace SmartParking.Features.Payments.DTOs;

public record PaymentDto(
    int PaymentID,
    double Amount,
    string Method,
    string Status,
    DateTime? PaidAt,
    int BookingID
);
