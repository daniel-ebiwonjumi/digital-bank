import "package:digital_bank/ui/cards/cards_view.dart";
import "package:digital_bank/ui/customer_care/customer_care_view.dart";
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
        onDestinationSelected: (int index) {
          setState(() {
            currentPageIndex = index;
          });
        },
        indicatorColor: const Color.fromARGB(255, 144, 213, 146),
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
            icon: Icon(Icons.atm_outlined),
            label: 'Customer Care',
          ),
        ],
      ),
      body: <Widget>[HomeView(), CardsView(), CustomerCareView()][currentPageIndex],
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
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.account_circle),
                const Text('Hi, user\'s name'),
                const Expanded(child: Icon(Icons.notifications)),
                const Icon(Icons.help_center),
              ],
            ),

            Container(
              height: MediaQuery.sizeOf(context).height / 5,
              width: double.infinity,
              color: Colors.lightGreen,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
              ),
              margin: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Column(
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.verified_user_outlined),
                          const Text('Available'),
                          const Icon(Icons.visibility),
                        ],
                      ),
                      //TODO: remove the hard coded balance
                      //TODO: and use the balance from the backend later
                      const Text('₦3000.50', style: TextStyle(fontSize: 32)),
                      //TODO: Use the account number from the backend
                      const Text('Account Number: 8101435550'),
                    ],
                  ),
                  Expanded(
                    child: Icon(Icons.notifications)
                  ),
                ],
              ),
            ),

            Container(
              height: MediaQuery.sizeOf(context).height / 6,
              margin: EdgeInsets.all(6),
              padding: EdgeInsets.all(6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    children: [
                      const Icon(Icons.person_pin),
                      const Text('Transfer to same bank'),
                    ],
                  ),
                  Column(
                    children: [
                      const Icon(Icons.account_balance),
                      const Text('Transfer to other bank'),
                    ],
                  ),
                  Column(
                    children: [
                      const Icon(Icons.wallet),
                      const Text('Add money'),
                    ],
                  ),
                ],
              ),
            ),

            Container(
                margin: EdgeInsets.all(6),
              padding: EdgeInsets.all(6),
              height: MediaQuery.sizeOf(context).height / 6,
              child: Column(
                children: [
                  Row(
                    children: [
                      Column(
                        children: [
                          const Icon(Icons.network_cell),
                          const Text('Buy Airtime'),
                        ],
                      ),
                      Column(
                        children: [
                          const Icon(Icons.savings),
                          const Text('Get Loan'),
                        ],
                      ),
                      Column(
                        children: [
                          const Icon(Icons.online_prediction),
                          const Text('Check monthly insight'),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

Container(
              height: MediaQuery.sizeOf(context).height / 6,
              margin: EdgeInsets.all(6),
              padding: EdgeInsets.all(6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    children: [
                      const Icon(Icons.history),
                      const Text('Transaction History'),
                    ],
                  ),
                  Column(
                    children: [
                      const Icon(Icons.settings),
                      const Text('Settings'),
                    ],
                  ),
            Container(
              color: const Color.fromARGB(255, 84, 157, 87),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.check_box_outlined),
                  //TODO: Add the history from the backend here later
                  const Text('Transfer to ....'),
                  const Text('₦500'),
                  const Text('Transactions'),
                  const Icon(Icons.arrow_right),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
