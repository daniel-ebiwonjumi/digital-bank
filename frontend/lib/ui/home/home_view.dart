import "package:flutter/material.dart";

class HomeView extends StatefulWidget{
    const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
int currentPageIndex = 0;
@override
Widget build (BuildContext context) {
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
            icon: Badge(child: Icon(Icons.notifications_sharp)),
            label: 'Notifications',
          ),]),
    body: <Widget>[HomePage(),][currentPageIndex],
     
    
);
}
}

class HomePage extends StatelessWidget {
  const HomePage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea( child: 
       SingleChildScrollView(
        child: Column(
            children: [ 
                Row(
                  mainAxisSize: MainAxisSize.min,
                    children: [
                       const Icon(Icons.account_circle),
                       const  Text ('Hi, user\'s name'),
                       const Expanded ( child: Icon(Icons.notifications)),
                       const Icon(Icons.help_center),
                    ]
                ),
    
    
                Container(
                  height: MediaQuery.sizeOf(context).height/5,
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
                               const Icon(Icons.visibility)
                            ]),
                            //TODO: remove the hard coded balance 
                            //TODO: and use the balance from the backend later
                            const Text('₦3000.50',
                            style: TextStyle(fontSize: 32),),
                            const Text('Earned today +14.43')
                        ]),
                       Expanded(child: Container (
                        color: Colors.transparent,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6)
                        ),
                        padding: EdgeInsets.only(top: 12),
                          child: Row(
                            children: [
                              Icon(Icons.add),
                              Text('Add money'),
                            ],
                          )))]
                    )
                ),
    
    
    Container(
      color: const Color.fromARGB(255, 84, 157, 87),
      child: 
    Row(
      mainAxisSize: MainAxisSize.min,
      children: [
    const Icon(Icons.check_box_outlined),
    //TODO: Add the history from the backend here later 
    const Text('Transfer to ....'),
    const Text('₦500'),
    const Text('Transactions'),
    const Icon(Icons.arrow_right)
      ],
    ),
    ),
    
    
    Container(
      margin: EdgeInsets.all(6),
      padding: EdgeInsets.all(6),
      child: Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
    Column(children: [
      const Icon(Icons.person_pin),
      const Text('To same bank')
    ],),
      Column(
                      children: [
                        const Icon(Icons.account_balance),
                        const Text('To other bank'),
                      ],
                    ),
                      Column(
                      children: [
                        const Icon(Icons.wallet),
                        const Text('Save'),
                      ],
                    ),
                      Column(
                      children: [
                        const Icon(Icons.savings),
                        const Text('Loan'),
                      ],
                    ),
    
      ],)
    ),
    
    Container(
      height: MediaQuery.sizeOf(context).height / 4,
      child: Column(children: [ 
    Row(children: [
       Column(
                        children: [
                          const Icon(Icons.network_cell),
                          const Text('Airtime'),
                        ],
       ),
    Column(
                          children: [
                            const Icon(Icons.online_prediction),
                            const Text('Data'),
                          ],
                        ),
                         Column(
                          children: [
                            const Icon(Icons.casino),
                            const Text('Betting'),
                          ],
                        ),
                         Column(
                          children: [
                            const Icon(Icons.tv),
                            const Text('TV'),
                          ],
                        ),
    ],),
    Row(children: [
       Column(
                          children: [
                            const Icon(Icons.lock),
                            const Text('Fixed'),
                          ],
                        ),
                         Column(
                          children: [
                            const Icon(Icons.money),
                            const Text('Loan Center'),
                          ],
                        ),
                         Column(
                          children: [
                            const Icon(Icons.people),
                            const Text('Invitation'),
                          ],
                        ),
                         Column(
                          children: [
                            const Icon(Icons.more),
                            const Text('More'),
                          ],
                        )
      
    ],),
    
      
      
      ]
      ),
    )
    
    
    
            ]
        )
       ) 
    );
  }
}