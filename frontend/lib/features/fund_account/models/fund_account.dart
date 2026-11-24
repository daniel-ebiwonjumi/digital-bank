import 'package:equatable/equatable.dart';

/// Amount limits enforced by the form and the bloc.
/// Placeholders: keep these in sync with the limits your backend enforces.
abstract final class FundingLimits {
  static const double minimumNaira = 100;
  static const double maximumNaira = 1000000;

  static bool isWithinLimits(double amountInNaira) {
    return amountInNaira.isFinite &&
        amountInNaira >= minimumNaira &&
        amountInNaira <= maximumNaira;
  }
}

/// The two ways a user can fund their account.
enum FundingMethod {
  card('card', 'Card', 'Pay with your debit card'),
  bankTransfer('bank_transfer', 'Bank transfer', 'Transfer from your bank app');

  const FundingMethod(this.apiValue, this.label, this.description);

  /// Sent to the backend as `channel`.
  final String apiValue;
  final String label;
  final String description;
}

/// Response of POST /wallet/fund/initialize.
class FundingSession extends Equatable {
  const FundingSession({
    required this.authorizationUrl,
    required this.reference,
  });

  /// Throws [FormatException] if the response is malformed or the checkout
  /// URL is not https.
  factory FundingSession.fromJson(Map<String, dynamic> json) {
    final url = json['authorizationUrl'];
    final reference = json['reference'];

    if (url is! String || reference is! String || reference.isEmpty) {
      throw const FormatException('Invalid funding session');
    }

    final uri = Uri.tryParse(url);
    if (uri == null || uri.scheme != 'https') {
      throw const FormatException('Checkout URL must use https');
    }

    return FundingSession(authorizationUrl: url, reference: reference);
  }

  final String authorizationUrl;
  final String reference;

  @override
  List<Object?> get props => [authorizationUrl, reference];
}

enum FundingStatusType {
  success,
  pending,
  failed;

  /// Anything unrecognised is treated as pending, so the app never shows
  /// "success" unless the backend says so explicitly.
  static FundingStatusType fromApi(String? value) => switch (value) {
        'success' => FundingStatusType.success,
        'failed' => FundingStatusType.failed,
        _ => FundingStatusType.pending,
      };
}

/// Response of GET /wallet/fund/verify/:reference.
class FundingStatus extends Equatable {
  const FundingStatus({required this.reference, required this.type});

  /// Throws [FormatException] if the response is malformed.
  factory FundingStatus.fromJson(Map<String, dynamic> json) {
    final reference = json['reference'];
    if (reference is! String || reference.isEmpty) {
      throw const FormatException('Invalid funding status');
    }

    final status = json['status'];
    return FundingStatus(
      reference: reference,
      type: FundingStatusType.fromApi(status is String ? status : null),
    );
  }

  final String reference;
  final FundingStatusType type;

  @override
  List<Object?> get props => [reference, type];
}