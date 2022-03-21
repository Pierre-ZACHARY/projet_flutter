import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../class/Bandnames.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage(BuildContext context, User user, {Key? key, required this.title}) : super(key: key){
    print(user.email);
    print(user.emailVerified);
    print(user.displayName);
    print(user.uid);
  }
  final String title;
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}


class _MyHomePageState extends State<MyHomePage> {

  void logout(){
    FirebaseAuth.instance.signOut();
  }

  Widget _buildListItem(BuildContext context, DocumentSnapshot<Bandnames> bnSnapShot){

    Bandnames bn = bnSnapShot.data()!;
    return ListTile(
      title: Row(
        children: [
          Expanded(child: Text(bn.name)),
          Text(bn.count.toString())
        ],
      ),
      onTap: ()=>{
        Bandnames.addCount(bnSnapShot.reference, 1),
        logout()
      },
    );
  }

  @override
  Widget build(BuildContext context) {


    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: bandnamesStream,
          builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {

            if (snapshot.hasError) {
              return Text('Something went wrong');
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Text("Loading");
            }
            return ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) => _buildListItem(context, snapshot.data!.docs[index] as DocumentSnapshot<Bandnames>),
            );
          },

        )
    );
  }
}