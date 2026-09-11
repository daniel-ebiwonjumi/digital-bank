enum TransactionType { transfer, airtime, data, deposit, bill, withdrawal }

extension TransactionTypeExtension on TransactionType {
  static TransactionType fromString(String value) {
    return TransactionType.values.firstWhere(
      (type) => type.name == value,
      orElse: () => TransactionType.transfer,
    );
  }
}

class Transaction {
  final String id;
  final String title;
  final String amount;
  final String currency;
  final TransactionType type;
  final bool isCredit;
  final DateTime createdAt;

  const Transaction({
    required this.id,
    required this.title,
    required this.amount,
    required this.currency,
    required this.type,
    required this.isCredit,
    required this.createdAt,
  });

  factory Transaction.fromMap(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'] as String,
      title: json['title'] as String,
      amount: json['amount'].toString(),
      currency: json['currency'] as String,
      type: TransactionTypeExtension.fromString(json['type'] as String,),
      isCredit: json['isCredit'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String,),
    );
  }
}
