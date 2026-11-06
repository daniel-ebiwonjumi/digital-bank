class WalletModel {
      final String walletId;
        final String accountNumber;
          final String accountName;
            final String currency;
              final String availableBalance;
                final String ledgerBalance;

                  const WalletModel({
                      required this.walletId,
                          required this.accountNumber,
                              required this.accountName,
                                  required this.currency,
                                      required this.availableBalance,
                                          required this.ledgerBalance,
                                            });

                                              factory WalletModel.fromJson(Map<String, dynamic> json) {
                                                  return WalletModel(
                                                        walletId: json['walletId'] as String,
                                                              accountNumber: json['accountNumber'] as String,
                                                                    accountName: json['accountName'] as String,
                                                                          currency: json['currency'] as String,
                                                                                availableBalance: json['availableBalance'] as String,
                                                                                      ledgerBalance: json['ledgerBalance'] as String,
                                                                                          );
                                                                                            }
                                                                                            }
