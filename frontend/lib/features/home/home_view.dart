import "package:digital_bank/features/cards/cards_view.dart";
import "package:digital_bank/features/customer_care/customer_care_view.dart";
import "package:flutter/material.dart";

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  int currentPageIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentPageIndex,
        onDestinationSelected: (int index) {
          setState(() {
            currentPageIndex = index;
          });
        },
        indicatorColor: const Color.fromARGB(255, 165, 179, 190),
        destinations: const <Widget>[
          NavigationDestination(
            selectedIcon: Icon(Icons.home),
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.atm),
            icon: Icon(Icons.atm_outlined),
            label: 'Cards',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.support_agent),
            icon: Icon(Icons.support_agent_outlined),
            label: 'Customer Care',
          ),
        ],
      ),
      body: [
        IndexedStack(
          index: currentPageIndex,
          children: const [HomeView(), CardsView(), CustomerCareView()],
        ),
      ][currentPageIndex],
    );
  }
}

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          children: [
            Row(
              children: const [
                Icon(Icons.account_circle),
                Text('Hi, user\'s name'),
                Spacer(),
                Icon(Icons.notifications),
                Icon(Icons.help_center),
              ],
            ),

            Container(
              width: double.infinity,

              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.blue,
              ),
              margin: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.verified_user_outlined,
                            color: Colors.black,
                          ),
                          SizedBox(width: 5),
                          const Text('Available'),
                          SizedBox(width: 5),
                          const Icon(Icons.visibility, color: Colors.black),
                        ],
                      ),

                      //TODO: remove the hard coded balance
                      //TODO: and use the balance from the backend later
                      const Text('₦3000.50', style: TextStyle(fontSize: 32)),
                      //TODO: Use the account number from the backend
                      const Text('Account Number: 8101435550'),
                    ],
                  ),
                  Icon(Icons.notifications),
                ],
              ),
            ),

            GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                QuickAction(
                  icon: Icons.person_pin,
                  label: 'Transfer to same bank',
                  onTap: () {},
                ),
                QuickAction(
                  icon: Icons.account_balance,
                  label: 'Transfer to other bank',
                  onTap: () {},
                ),
                QuickAction(
                  icon: Icons.wallet,
                  label: 'Add money',
                  onTap: () {},
                ),
                QuickAction(
                  icon: Icons.network_cell,
                  label: 'Buy Airtime',
                  onTap: () {},
                ),
                QuickAction(
                  icon: Icons.savings,
                  label: 'Get Loan',
                  onTap: () {},
                ),
                QuickAction(
                  icon: Icons.online_prediction,
                  label: 'Monthly insight',
                  onTap: () {},
                ),
                QuickAction(
                  icon: Icons.history,
                  label: 'Transaction History',
                  onTap: () {},
                ),
                QuickAction(
                  icon: Icons.settings,
                  label: 'Settings',
                  onTap: () {},
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class QuickAction extends StatelessWidget {
  const QuickAction({
    super.key,
    required this.icon,
    required this.label,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon),
            const SizedBox(height: 8),
            Text(label, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
