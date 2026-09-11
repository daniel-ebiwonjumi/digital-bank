import 'package:digital_bank/data/repositories/home_repository/home_data.dart';
import 'package:digital_bank/data/repositories/home_repository/transaction.dart';
import 'package:digital_bank/data/repositories/home_repository/wallet.dart';
import 'package:digital_bank/ui/home/home_view_model.dart';
import 'package:flutter/material.dart';
import 'package:digital_bank/ui/auth/auth_view_model.dart';

class HomeView extends StatefulWidget {
  final AuthViewModel authViewModel;
  final HomeViewModel homeViewModel;

  const HomeView({
    super.key,
    required this.authViewModel,
    required this.homeViewModel,
  });

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  @override
  void initState() {
    super.initState();

    widget.homeViewModel.addListener(_onHomeViewModelChanged);
    widget.homeViewModel.loadHome();
  }

  @override
  void dispose() {
    widget.homeViewModel.removeListener(_onHomeViewModelChanged);
    super.dispose();
  }

  void _onHomeViewModelChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.authViewModel.user;
    final HomeViewModel = widget.homeViewModel;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_none_outlined),
          ),

          MenuAnchor(
            menuChildren: [
              MenuItemButton(
                leadingIcon: const Icon(Icons.logout),
                onPressed: () async {
                  await widget.authViewModel.logout();
                },
                child: const Text(
                  'Logout',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
          MenuItemButton(),
          MenuItemButton(),
        ],
      ),
      body: _buildBody(HomeViewModel),
    );
  }

  Widget _buildBody(HomeViewModel homeViewModel) {
    if (homeViewModel.isLoading && !homeViewModel.hasData) {
      return const Center(child: CircularProgressIndicator());
    }

    if (homeViewModel.hasError && !homeViewModel.hasData) {
      return _ErrorView(
        message: homeViewModel.errorMessage ?? 'something went wrong.',
        onRetry: homeViewModel.loadHome,
      );
    }

    final HomeData? data = homeViewModel.homeData;

    if (data == null) {
      return const SizedBox.shrink();
    }

    return RefreshIndicator(
      onRefresh: homeViewModel.refresh,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Good morning, ${data.user.name}',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 20),

            WalletCard(
              wallet: data.wallet,
              balanceVisible: homeViewModel.balanceVisible,
              onToggleBalance: homeViewModel.toggleBalanceVisibility,
            ),
            const SizedBox(height: 28),
            const SizedBox(height: 28),

            const Text(
              'Quick Actions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 28),

            PromoBanner(
              title: 'Your money, your way',
              subtitle: 'Manage your finances easily',
              onTap: () {
                //TODO Navigate to promotion.
              },
            ),

            const SizedBox(height: 28),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Recent Transactions',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () {
                    //TODO: Navigate to transaction history
                  },
                  child: const Text('See all'),
                ),

                const SizedBox(height: 8),

                TransactionList(transactions: data.transactions),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _handleQuickAction(String action) {
    switch (action) {
      case 'transfer':
        //TODO: Navigate to transfer.
        break;

      case 'airtime':
        //TODO: Navigate to airtime
        break;

      case 'Bills':
        //TODO: Navigate to bills
        break;
    }
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({super.key, required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cloud_off_outlined, size: 48),
            const SizedBox(height: 16),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: onRetry, child: const Text('Try again')),
          ],
        ),
      ),
    );
  }
}

class WalletCard extends StatelessWidget {
  const WalletCard({
    super.key,
    required this.wallet,
    required this.balanceVisible,
    required this.onToggleBalance,
  });
  final Wallet wallet;
  final bool balanceVisible;
  final VoidCallback onToggleBalance;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Available Balance',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: onToggleBalance,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: Icon(
                  balanceVisible
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),
          Text(
            balanceVisible
                ? '${wallet.currency} ${wallet.balance}'
                : '********',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 28,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    //TODO: Navigate to funding screen,
                  },
                  child: const Text('Add Money'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    //TODO: Navigate to transfer screen
                    style:
                    OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white),
                    );
                  },
                  child: const Text('Transfer'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class QuickActions extends StatelessWidget {
  final void Function(String action)? onActionSelected;
  const QuickActions({super.key, this.onActionSelected});

  @override
  Widget build(BuildContext context) {
    final actions = [
      const _QuickAction(title: 'Transfer', icon: Icons.send_outlined),

      const _QuickAction(title: 'Airtime', icon: Icons.phone_android_outlined),

      const _QuickAction(title: 'Bills', icon: Icons.receipt_long_outlined),
    ];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: actions.map((action) {
        return Expanded(
          child: GestureDetector(
            onTap: () {
              onActionSelected?.call(action.title);
            },
            child: Column(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(action.icon),
                ),
                const SizedBox(height: 8),
                Text(action.title, style: const TextStyle(fontSize: 12)),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _QuickAction {
  final String title;
  final IconData icon;

  const _QuickAction({required this.title, required this.icon});
}

class PromoBanner extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  const PromoBanner({
    super.key,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondaryContainer,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(subtitle),
          ],
        ),
      ),
    );
  }
}

class TransactionList extends StatelessWidget {
  final List<Transaction> transactions;

  const TransactionList({super.key, required this.transactions});

  @override
  Widget build(BuildContext context) {
    if (transactions.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(child: Text('No transactions yet.')),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),

      itemBuilder: (context, index) {
        final transaction = transactions[index];

        return ListTile(
          contentPadding: EdgeInsets.zero,
          leading: CircleAvatar(
            backgroundColor: Colors.grey.shade100,
            child: Icon(_iconFor(transaction.type)),
          ),
          title: Text(
            transaction.title,
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          subtitle: Text(_formatDate(transaction.createdAt)),
          trailing: Text(
            '${transaction.isCredit ? '+' : '-'}'
            '${transaction.currency}'
            '${transaction.amount}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: transaction.isCredit ? Colors.green : null,
            ),
          ),
        );
      },
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemCount: transactions.length,
    );
  }

  IconData _iconFor(TransactionType type) {
    return switch (type) {
      TransactionType.transfer => Icons.send_outlined,
      TransactionType.airtime => Icons.phone_android_outlined,
      TransactionType.data => Icons.wifi_outlined,
      TransactionType.bill => Icons.receipt_long_outlined,
      TransactionType.deposit => Icons.account_balance_wallet_outlined,
      TransactionType.withdrawal => Icons.arrow_upward_outlined,
    };
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }
}
