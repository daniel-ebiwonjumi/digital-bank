import 'package:equatable/equatable.dart';

abstract final class TransferRules {
  static const int accountNumberLength = 10;
  static const int pinLength = 4;
  static const int maxNarrationLength = 100;

  /// Placeholders: keep these in sync with the limits your backend enforces.
  static const double minimumNaira = 1;
  static const double maximumNaira = 5000000;

  static bool isAmountWithinLimits(double amountInNaira) {
    return amountInNaira.isFinite &&
        amountInNaira >= minimumNaira &&
        amountInNaira <= maximumNaira;
  }

  static bool isValidAccountNumber(String value) {
    return value.length == accountNumberLength &&
        RegExp(r'^\d+$').hasMatch(value);
  }

  static bool isValidPin(String value) {
    return value.length == pinLength && RegExp(r'^\d+$').hasMatch(value);
  }
}

/// Response of GET /transfers/recipient/:accountNumber.
class Recipient extends Equatable {
  const Recipient({required this.accountNumber, required this.accountName});

  /// Throws [FormatException] if the response is malformed.
  factory Recipient.fromJson(Map<String, dynamic> json) {
    final accountNumber = json['accountNumber'];
    final accountName = json['accountName'];

    if (accountNumber is! String ||
        !TransferRules.isValidAccountNumber(accountNumber) ||
        accountName is! String ||
        accountName.trim().isEmpty) {
      throw const FormatException('Invalid recipient');
    }

    return Recipient(
      accountNumber: accountNumber,
      accountName: accountName.trim(),
    );
  }

  final String accountNumber;
  final String accountName;

  @override
  List<Object?> get props => [accountNumber, accountName];
}

/// What the user has reviewed and is about to confirm.
class TransferDraft extends Equatable {
  const TransferDraft({
    required this.recipient,
    required this.amountInNaira,
    required this.narration,
  });

  final Recipient recipient;
  final double amountInNaira;
  final String narration;

  @override
  List<Object?> get props => [recipient, amountInNaira, narration];
}

/// Response of POST /transfers.
class TransferReceipt extends Equatable {
  const TransferReceipt({
    required this.reference,
    required this.amountInNaira,
    required this.recipient,
    required this.narration,
    required this.createdAt,
  });

  /// Throws [FormatException] if the response is malformed.
  factory TransferReceipt.fromJson(Map<String, dynamic> json) {
    final reference = json['reference'];
    final amount = json['amount'];
    final recipient = json['recipient'];
    final narration = json['narration'];
    final createdAt = json['createdAt'];

    if (reference is! String ||
        reference.isEmpty ||
        amount is! num ||
        recipient is! Map<String, dynamic> ||
        createdAt is! String) {
      throw const FormatException('Invalid transfer receipt');
    }

    final date = DateTime.tryParse(createdAt);
    if (date == null) throw const FormatException('Invalid receipt date');

    return TransferReceipt(
      reference: reference,
      amountInNaira: amount.toDouble(),
      recipient: Recipient.fromJson(recipient),
      narration: narration is String ? narration : '',
      createdAt: date.toLocal(),
    );
  }

  final String reference;
  final double amountInNaira;
  final Recipient recipient;
  final String narration;
  final DateTime createdAt;

  @override
  List<Object?> get props => [
    reference,
    amountInNaira,
    recipient,
    narration,
    createdAt,
  ];
}
