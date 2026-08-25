import 'package:digital_bank/data/repositories/home_repository/transaction.dart';
import 'package:digital_bank/data/repositories/home_repository/wallet.dart';
import 'package:flutter/material.dart';
import 'package:digital_bank/ui/auth/auth_view_model.dart';

class HomeView extends StatelessWidget {
  final AuthViewModel authViewModel;

  const HomeView({super.key, required this.authViewModel});

  @override
  Widget build(BuildContext context) {
    final user = authViewModel.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            onPressed: () async {
              await authViewModel.logout();
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Welcome ${user?.name ?? ''}',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            Text(user?.email ?? ''),

            ElevatedButton(
              onPressed: () async {
                await authViewModel.logout();
              },
              child: const Text('logout'),
            ),
          ],
        ),
      ),
    );
  }
}

class WalletCard extends StatelessWidget {
  const WalletCard({super.key, required this.wallet, required this.balanceVisible, required this.onToggleBalance});
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
          Row(children: [
            const Text(
              'Available Balance',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14
              ),
            ), 
            const SizedBox(width: 8),
            IconButton(
              onPressed: onToggleBalance,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              icon: Icon(
                balanceVisible ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                color: Colors.white,
                size: 20,
              )
            )
          ],),

          const SizedBox(height: 8),
          Text(
            balanceVisible ? '${wallet.currency} ${wallet.balance}' : '********', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 28, color: Colors.white),
          ),
          const SizedBox(height: 24),
          Row(children: [
            Expanded(child: ElevatedButton(onPressed: (){
              //TODO: Navigate to funding screen,
              
            },
            child: const Text('Add Money'),
            )),
            const SizedBox(width: 12,),
            Expanded(child: OutlinedButton(
              onPressed: (){
                //TODO: Navigate to transfer screen
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white)
                )
              },
              child: const Text('Transfer'),),)
          ])
        ],
      ),
    );
  }
}

class QuickActions extends StatelessWidget {
  final void Function(String action)? onActionSelected;
  const QuickActions({super.key, this.onActionSelected,});


  @override
  Widget build(BuildContext context) {
    final actions = [
      const _QuickAction(
        title: 'Transfer',
        icon: Icons.send_outlined,
      ),

      const _QuickAction(
        title: 'Airtime',
        icon: Icons.phone_android_outlined
      ),

      const _QuickAction(title: 'Bills',
      icon: Icons.receipt_long_outlined),
    ];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: actions.map((action) {
        return Expanded(
          child: GestureDetector(onTap: (){
            onActionSelected?.call(action.title);
          },
          child: Column(children: [
            Container(width: 52, height: 52,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(action.icon),
            ),
            const SizedBox(height: 8,),
            Text(
              action.title,
              style: const TextStyle(fontSize: 12,)
            )
          ],),
          )
        );
      }).toList()
    );
  }
}

class _QuickAction {
  final String title;
  final IconData icon;

  const _QuickAction ({
    required this.title,
    required this.icon,
  });
}

class PromoBanner extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  
  const PromoBanner({super.key, required this.title, required this.subtitle, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(16)
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        Text(subtitle),
      ],)
      ),
    );
  }
}

class TransactionList extends StatelessWidget {
  final List<Transaction> transactions;
  
  const TransactionList({super.key, required this.transactions});

  @override
  Widget build(BuildContext context) {
   if (transactions.isEmpty){
    return const Padding(padding: EdgeInsets.symmetric(vertical: 24),
    child: Center(child: Text('No transactions yet.'),),
    );
   }

   return ListView.separated(
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),

    itemBuilder: (context, index){
      final transaction = transactions[index];

      return ListTile(contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: Colors.grey.shade100,
        child: Icon(_iconFor(transaction.type)),
      ),
      title: Text(
        transaction.title, style: TextStyle(fontWeight: FontWeight.w600,),
      ),
      subtitle: Text(_formatDate(transaction.createdAt)),
      trailing: Text(
        '${transaction.isCredit ? '+' : '-'}'
        '${transaction.currency}'
        '${transaction.amount}',
        style: TextStyle(fontWeight: FontWeight.bold,
        color: transaction.isCredit ? Colors.green : null,)

      ),
      );
    }, separatorBuilder: (_, __) => 
    const Divider(height: 1,)
    , itemCount: transactions.length);
  }

  IconData _iconFor (TransactionType type){
    return switch(type){
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