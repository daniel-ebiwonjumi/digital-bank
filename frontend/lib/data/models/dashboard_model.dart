class DashboardModel {
      final User user;
        final WalletModel wallet;
          final List<TransactionModel> recentTransactions;
            final NotificationModel notifications;

              const DashboardModel({
                  required this.user,
                      required this.wallet,
                          required this.recentTransactions,
                              required this.notifications,
                                });

                                  factory DashboardModel.fromJson(Map<String, dynamic> json) {
                                      return DashboardModel(
                                            user: User.fromJson(json['user']),
                                                  wallet: WalletModel.fromJson(json['wallet']),
                                                        recentTransactions: (json['recentTransactions'] as List)
                                                                  .map((item) => TransactionModel.fromJson(item))
                                                                            .toList(),
                                                                                  notifications: NotificationModel.fromJson(json['notifications']),
                                                                                      );
                                                                                        }
                                                                                        }
}