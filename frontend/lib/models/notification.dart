class NotificationModel {
  final int? notificationID;
  final String type;
  final String message;
  final DateTime sentAt;
  final String channel;

  const NotificationModel({
    this.notificationID,
    required this.type,
    required this.message,
    required this.sentAt,
    required this.channel,
  });

  String get typeLabel {
    switch (type) {
      case 'booking_confirmation':
        return 'Booking Confirmation';
      case 'expiry_warning':
        return 'Expiry Warning';
      case 'violation_alert':
        return 'Violation Alert';
      default:
        return type;
    }
  }

  String get timeText {
    final hour12 = sentAt.hour == 0
        ? 12
        : (sentAt.hour > 12 ? sentAt.hour - 12 : sentAt.hour);
    final minute = sentAt.minute.toString().padLeft(2, '0');
    final suffix = sentAt.hour >= 12 ? 'PM' : 'AM';
    return '$hour12:$minute $suffix';
  }

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      notificationID: json['notificationID'] as int?,
      type: json['type'] as String? ?? '',
      message: json['message'] as String? ?? '',
      sentAt: json['sentAt'] != null
          ? DateTime.parse(json['sentAt'] as String)
          : DateTime.now(),
      channel: json['channel'] as String? ?? 'push',
    );
  }
}