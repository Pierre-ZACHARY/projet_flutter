import 'package:flutter/material.dart';
import 'package:projet_flutter/utils/constant.dart';
import '/modele/Bandnames.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatPage extends StatefulWidget{
  const ChatPage({Key? key, }) : super(key: key);

  void logout(){
    FirebaseAuth.instance.signOut();
  }

  @override
  State<StatefulWidget> createState() => _ChatPageState();

}

class _ChatPageState extends State<ChatPage>{

  Widget _buildListItem(BuildContext context, DocumentSnapshot<Bandnames> bnSnapShot){

    Bandnames bn = bnSnapShot.data()!;
    return ListTile(
      title: Row(
        children: [
          Expanded(child: Text(bn.name, style: TextConstants.defaultPrimary,)),
          Text(bn.count.toString(), style: TextConstants.defaultPrimary,)
        ],
      ),
      onTap: ()=>{
        Bandnames.addCount(bnSnapShot.reference, 1),
        widget.logout()
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: ColorConstants.background,
        body: StreamBuilder<QuerySnapshot>(
          stream: bandnamesStream,
          builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
              return const Text('Something went wrong', style: TextConstants.titlePrimary);
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Text("Loading", style: TextConstants.titlePrimary);
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