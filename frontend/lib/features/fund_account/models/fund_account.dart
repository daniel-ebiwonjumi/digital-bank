import 'package:equatable/equatable.dart';

enum FundingMethod {
  card('card', 'Card', 'Fund your account with your debit card'),
  banktransfer(
    'bank_transfer',
    'Bank Transfer',
    'Fund your account with bank transfer',
  );

  const FundingMethod(this.apiValue, this.label, this.description);

  final String apiValue;
  final String label;
  final String description;
}

class FundingSession extends Equatable {
  const FundingSession({
    required this.authorizationUrl,
    required this.reference,
  });

  factory FundingSession.fronJson(Map<String, dynamic> json) {
    return FundingSession(
      authorizationUrl: json['authorizationUrl'] as String,
      reference: json['reference'] as String,
    );
  }

  final String authorizationUrl;
  final String reference;

  @override
  List<Object> get props => [authorizationUrl, reference];
}

enum FundingStatusType {
  success,
  failure,
  pending;

  static FundingStatusType fromApi(String? value) => switch (value) {
    'success' => FundingStatusType.success,
    'failure' => FundingStatusType.failure,
    _ => FundingStatusType.pending,
  };
}

class FundingStatus extends Equatable {
  const FundingStatus({required this.reference, required this.type});

  factory FundingStatus.fronJson(Map<String, dynamic> json) {
    return FundingStatus(
      reference: json['reference'] as String,
      type: FundingStatusType.fromApi(json['status'] as String),
    );
  }
  final String reference;
  final FundingStatusType type;

  @override
  List<Object?> get props => [reference, type];
}
