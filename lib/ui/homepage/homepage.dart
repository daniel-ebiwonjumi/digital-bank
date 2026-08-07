import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Homepage extends StatelessWidget{
  const Homepage({super.key});

  @override
  Widget build(BuildContext context){
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [Text('Homepage', textAlign: TextAlign.left,),
              CustomAppBar(),
                  CreatePost(),
                  CreateStatus(),
                  Posts(),
                ],),
        ),
      ),
    );
  }
}

class CreateStatus extends StatelessWidget {
  const CreateStatus({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 150,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: Colors.primaries.length,
        itemBuilder: (context, index){
          final color = Colors.primaries[index];
          return Container(width: 160, color: color);
        }
      ),
    );
  }
}

class CreatePost extends StatelessWidget {
  const CreatePost({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(children: [Icon((Icons.person)), Expanded(
      child: TextFormField(
        decoration: InputDecoration(
          hintText: 'What\'s on your mind'
        ),
       
      ),
    ),  Icon(Icons.photo)],);
  }
}

class CustomAppBar extends StatelessWidget{
const CustomAppBar({super.key});

@override
Widget build(BuildContext context){
  return Container(padding: EdgeInsets.only(bottom: 5),
  child: Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween
    ,children: [
    Icon(
    Icons.home,
    ),
    Icon(Icons.people),
    Icon(Icons.messenger),
    Icon(Icons.workspace_premium_outlined),
    Icon(Icons.notifications),
    Icon(Icons.video_library),

    Icon(Icons.sell),
    ],),);
}
}

class Posts extends StatelessWidget {
  const Posts({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Row(
           mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
           Row(children: [
            Icon(Icons.person),
            SizedBox(width: 8,),
            Text('First name Second name')
           ],),
            Icon(Icons.more_horiz)
          ],
        ),
        SizedBox(width: double.infinity, 
        child: Container(color: Colors.blue ,)
        )
      ],
    );
  }
}