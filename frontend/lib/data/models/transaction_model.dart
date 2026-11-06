class TransactionModel {
      final String id;
        final String reference;
          final String description;
            final String amount;
              final String direction;
                final String status;
                  final DateTime createdAt;

                    const TransactionModel({
                        required this.id,
                            required this.reference,
                                required this.description,
                                    required this.amount,
                                        required this.direction,
                                            required this.status,
                                                required this.createdAt,
                                                  });

                                                    factory TransactionModel.fromJson(Map<String, dynamic> json) {
                                                        return TransactionModel(
                                                              id: json['id'] as String,
                                                                    reference: json['reference'] as String,
                                                                          description: json['description'] as String,
                                                                                amount: json['amount'] as String,
                                                                                      direction: json['direction'] as String,
                                                                                            status: json['status'] as String,
                                                                                                  createdAt: DateTime.parse(json['createdAt'] as String),
                                                                                                      );
                                                                                                        }
                                                                                                        }
}