class Wallet {
  final String balance;
  final String currency;

  const Wallet({required this.balance, required this.currency});

  factory Wallet.fromMap(Map<String, dynamic> json) {
    return Wallet(
      balance: json['balance'] as String,
      currency: json['currency'] as String,
    );
  }
}
