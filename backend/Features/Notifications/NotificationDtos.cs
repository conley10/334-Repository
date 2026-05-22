namespace SmartParking.Features.Notifications;

public record NotificationDto(
    int NotificationID,
    string Type,
    string Message,
    DateTime SentAt,
    string Channel
);
