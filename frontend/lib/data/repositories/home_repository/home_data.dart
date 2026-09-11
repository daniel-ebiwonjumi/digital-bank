import 'package:digital_bank/data/repositories/home_repository/transaction.dart';
import 'package:digital_bank/data/repositories/home_repository/wallet.dart';
import 'package:digital_bank/data/repositories/user.dart';

class HomeData {
  final User user;
  final Wallet wallet;
  final List<Transaction> transactions;

  const HomeData({
    required this.user,
    required this.wallet,
    required this.transactions,
  });

  factory HomeData.fromMap(Map<String, dynamic> json) {
    return HomeData(
      user: User.fromMap(json['user'] as Map<String, dynamic>),
      wallet: Wallet.fromMap(json['wallet'] as Map<String, dynamic>),
      transactions: (json['transactions'] as List<dynamic>)
          .map((item) => Transaction.fromMap(item as Map<String, dynamic>))
          .toList(),
    );
  }
}
