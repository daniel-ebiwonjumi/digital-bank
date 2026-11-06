import "package:flutter/material.dart";

class HomeView extends StatelessWidget{
    const HomeView({super.key});

@override
Widget build (BuildContext context) {
return Scaffold(
    body: SafeArea(
       SingleChildScrollView(
        child: Column(
            children: [ 
                Row(
                    children: [
                        Text('user image'),
                        Text ('Welcome, the user\'s name'),
                       Expanded ( child: Text('Notify icon'))
                    ]
                ),

                Container(
                    child: Row(
                        children: [Column(children: [
                            Row(children: [
                                Text('First icon'),
                                Text('Available'),
                                Text('Show/hide icon')
                            ]),
                            Text('The balance according to the backend'),
                            Text('Earned today cashback')
                        ]),
                        Expanded(child: Container (child: Text('Add money')))]
                    )
                ),


Container(child: 
                Text('Showing of the transaction history, only one transaction though'),
)




            ]
        )
       ) 
    )
    
);
}
}