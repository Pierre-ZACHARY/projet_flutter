import 'package:flutter/material.dart';
import 'package:projet_flutter/modele/Discussion.dart';
import 'package:projet_flutter/modele/DiscussionsList.dart';
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

class UserinfoWrapper{
  late String label;
  late Userinfo value;
  UserinfoWrapper(Userinfo userinfo){
    label = userinfo.displayName;
    value = userinfo;
  }
}

class _ChatPageState extends State<ChatPage>{

  Widget _buildListItem(BuildContext context, String discussionId){
    return ListTile(
      title: Row(
        children: [
          Expanded(child: Text(discussionId, style: TextConstants.defaultPrimary,)),
        ],
      ),
      onTap: ()=>{
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
      _list.add(UserinfoWrapper(userinfo));
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
    Stream<DocumentSnapshot<DiscussionsList>> userDiscussions = DiscussionsList.getUserDiscussionsList(FirebaseAuth.instance.currentUser!.uid);
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
                  },
                  getSelectedValue: (UserinfoWrapper value) {
                    Discussion.openDiscussion([value.value.uid, FirebaseAuth.instance.currentUser!.uid]); // this prints the selected option which could be an object
                  }),
              Expanded(
                child: StreamBuilder<DocumentSnapshot<DiscussionsList>>(
                  stream: userDiscussions,
                  builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot<DiscussionsList>> snapshot) {
                    if (snapshot.hasError) {
                      return const Text('Something went wrong', style: TextConstants.titlePrimary);
                    }
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Text("Loading", style: TextConstants.titlePrimary);
                    }
                    if (snapshot.hasData && snapshot.data!.data() != null) {
                      return ListView.builder(
                        itemCount: snapshot.data!.data()!.discussionsIds.length,
                        itemBuilder: (context, index) => _buildListItem(context, snapshot.data!.data()!.discussionsIds[index]),
                      );
                    }
                    else{
                      return const Text("Aucune Discussion", style: TextConstants.defaultPrimary,);
                    }
                  },

                ),
              ),
            ],
          ),
        )
    );
  }

}