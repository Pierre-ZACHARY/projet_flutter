import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../class/Bandnames.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}


class _MyHomePageState extends State<MyHomePage> {

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
        FirebaseFirestore.instance.runTransaction((transaction) async {
          DocumentSnapshot<Bandnames> freshSnap = await transaction.get(bnSnapShot.reference);
          await transaction.update(freshSnap.reference, {
            'count': freshSnap.data()!.count + 1,
          });
        })
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final Stream<QuerySnapshot<Bandnames>> _bandnamesStream = FirebaseFirestore.instance.collection('bandnames').withConverter<Bandnames>(
      fromFirestore: (snapshot, _) => Bandnames.fromJson(snapshot.data()!),
      toFirestore: (bandnames, _) => bandnames.toJson(),
    ).snapshots();

    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: _bandnamesStream,
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