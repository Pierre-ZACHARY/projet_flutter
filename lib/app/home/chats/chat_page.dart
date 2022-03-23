import 'package:flutter/material.dart';
import 'package:projet_flutter/modele/UserInfo.dart';
import 'package:projet_flutter/utils/constant.dart';
import '/modele/Bandnames.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:textfield_search/textfield_search.dart';

class ChatPage extends StatefulWidget{
  const ChatPage({Key? key, }) : super(key: key);

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
      },
    );
  }

  TextEditingController myController = TextEditingController();
  // create a Future that returns List
  Future<List> fetchData() async {
    List _list = [];
    String _inputText = myController.text;
    Query<Userinfo> query = Userinfo.searchUser(_inputText);
    QuerySnapshot<Userinfo> querySnapshot = await query.limit(10).get();
    print(querySnapshot.docs.length);
    for(int i = 0; i < querySnapshot.docs.length; i++){
      QueryDocumentSnapshot<Userinfo> documentSnapshot = querySnapshot.docs[i];
      Userinfo userinfo = documentSnapshot.data();
      _list.add(userinfo.displayName);
    }
    return _list;
  }
  @override
  void dispose() {
    // Clean up the controller when the widget is removed from the
    // widget tree.
    //myController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: ColorConstants.background,
        body: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              TextFieldSearch(
                  label: "",
                  textStyle: TextConstants.defaultPrimary,
                  controller: myController,
                  decoration: InputDecorationBuilder().addLabel("Search").build(),
                  future: () {
                    return fetchData();
                  }),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
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

                ),
              ),
            ],
          ),
        )
    );
  }

}