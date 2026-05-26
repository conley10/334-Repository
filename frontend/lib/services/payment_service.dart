import 'api_client.dart';

class PaymentService {
  PaymentService({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  static const bool useRealApi = true;

  static const List<String> validMethods = [
    'card',
    'ApplePay',
    'GooglePay',
    'PayPal',
  ];

  Future<Map<String, dynamic>> processPayment({
    required int? bookingID,
    required String method,
    required double amount,
  }) async {
    if (bookingID == null) {
      throw ArgumentError('bookingID cannot be null');
    }

    if (!validMethods.contains(method)) {
      throw ArgumentError(
        'Invalid payment method: "$method". '
        'Must be one of: ${validMethods.join(", ")}',
      );
    }

    if (amount <= 0) {
      throw ArgumentError('Amount must be greater than 0, got: $amount');
    }

    if (!useRealApi) {
      await Future.delayed(const Duration(milliseconds: 600));
      return {
        'paymentID': 1,
        'bookingID': bookingID,
        'method': method,
        'amount': amount,
        'status': 'success',
        'paidAt': DateTime.now().toIso8601String(),
      };
    }

    final response = await _apiClient.post(
  '/payments',
  authenticated: false,
  body: {
    'bookingID': bookingID,
    'method': method,
    'amount': amount,
  },
);

    return response as Map<String, dynamic>;
  }
}