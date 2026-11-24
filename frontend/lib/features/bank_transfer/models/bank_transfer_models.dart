import 'package:equatable/equatable.dart';

abstract final class BankTransferRules {
  static const int accountNumberLength = 10;
  static const int maxNarrationLength = 100;

  /// Placeholders: keep these in sync with the limits your backend enforces.
  static const double minimumNaira = 100;
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
}

class Bank extends Equatable {
  const Bank({required this.code, required this.name});

  /// Returns null for a malformed entry, so one bad entry cannot break the
  /// whole bank list.
  static Bank? tryFromJson(Map<String, dynamic> json) {
    final code = json['code'];
    final name = json['name'];

    if (code is! String ||
        !RegExp(r'^[A-Za-z0-9]+$').hasMatch(code) ||
        name is! String ||
        name.trim().isEmpty) {
      return null;
    }
    return Bank(code: code, name: name.trim());
  }

  final String code;
  final String name;

  @override
  List<Object?> get props => [code, name];
}

/// A verified account at another bank.
class BankRecipient extends Equatable {
  const BankRecipient({
    required this.bank,
    required this.accountNumber,
    required this.accountName,
  });

  final Bank bank;
  final String accountNumber;
  final String accountName;

  @override
  List<Object?> get props => [bank, accountNumber, accountName];
}

/// What the user has reviewed and is about to confirm.
class BankTransferDraft extends Equatable {
  const BankTransferDraft({
    required this.recipient,
    required this.amountInNaira,
    required this.feeInNaira,
    required this.narration,
  });

  final BankRecipient recipient;
  final double amountInNaira;
  final double feeInNaira;
  final String narration;

  /// Amount plus fee: what leaves the wallet.
  double get totalInNaira => amountInNaira + feeInNaira;

  @override
  List<Object?> get props => [recipient, amountInNaira, feeInNaira, narration];
}

enum BankTransferStatus {
  success,
  pending,
  failed;

  /// Anything unrecognised is treated as pending, so the app never shows
  /// "success" unless the backend says so explicitly.
  static BankTransferStatus fromApi(String? value) => switch (value) {
    'success' => BankTransferStatus.success,
    'failed' => BankTransferStatus.failed,
    _ => BankTransferStatus.pending,
  };
}

/// Response of POST /bank-transfers and GET /bank-transfers/:reference.
class BankTransferReceipt extends Equatable {
  const BankTransferReceipt({
    required this.reference,
    required this.status,
    required this.amountInNaira,
    required this.feeInNaira,
    required this.recipient,
    required this.narration,
    required this.createdAt,
  });

  /// Throws [FormatException] if the response is malformed.
  factory BankTransferReceipt.fromJson(Map<String, dynamic> json) {
    final reference = json['reference'];
    final amount = json['amount'];
    final fee = json['fee'];
    final recipient = json['recipient'];
    final narration = json['narration'];
    final createdAt = json['createdAt'];

    if (reference is! String ||
        reference.isEmpty ||
        amount is! num ||
        !amount.isFinite ||
        amount <= 0 ||
        fee is! num ||
        !fee.isFinite ||
        fee < 0 ||
        recipient is! Map<String, dynamic> ||
        createdAt is! String) {
      throw const FormatException('Invalid transfer receipt');
    }

    final date = DateTime.tryParse(createdAt);
    final accountNumber = recipient['accountNumber'];
    final accountName = recipient['accountName'];
    final bank = Bank.tryFromJson({
      'code': recipient['bankCode'],
      'name': recipient['bankName'],
    });

    if (date == null ||
        accountNumber is! String ||
        !BankTransferRules.isValidAccountNumber(accountNumber) ||
        accountName is! String ||
        accountName.trim().isEmpty ||
        bank == null) {
      throw const FormatException('Invalid transfer receipt');
    }

    final status = json['status'];
    return BankTransferReceipt(
      reference: reference,
      status: BankTransferStatus.fromApi(status is String ? status : null),
      amountInNaira: amount.toDouble(),
      feeInNaira: fee.toDouble(),
      recipient: BankRecipient(
        bank: bank,
        accountNumber: accountNumber,
        accountName: accountName.trim(),
      ),
      narration: narration is String ? narration : '',
      createdAt: date.toLocal(),
    );
  }

  final String reference;
  final BankTransferStatus status;
  final double amountInNaira;
  final double feeInNaira;
  final BankRecipient recipient;
  final String narration;
  final DateTime createdAt;

  double get totalInNaira => amountInNaira + feeInNaira;

  BankTransferReceipt copyWith({BankTransferStatus? status}) {
    return BankTransferReceipt(
      reference: reference,
      status: status ?? this.status,
      amountInNaira: amountInNaira,
      feeInNaira: feeInNaira,
      recipient: recipient,
      narration: narration,
      createdAt: createdAt,
    );
  }

  @override
  List<Object?> get props => [
    reference,
    status,
    amountInNaira,
    feeInNaira,
    recipient,
    narration,
    createdAt,
  ];
}
