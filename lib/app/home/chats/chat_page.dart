import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:projet_flutter/app/home/chats/chat_room.dart';
import 'package:projet_flutter/modele/Discussion.dart';
import 'package:projet_flutter/modele/DiscussionsList.dart';
import 'package:projet_flutter/modele/Message.dart';
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


  Map<String, bool> muteIcons = Map();

  IconData getIcon(String id){
    if (muteIcons[id] == true){
      return Icons.volume_mute;
    }
    return Icons.volume_up;
  }

  Widget _buildListItem(BuildContext context, String discussionId){
    Stream<DocumentSnapshot<Discussion>> discussionStream = Discussion.getDiscussionStream(discussionId);
    return StreamBuilder<DocumentSnapshot<Discussion>>(
      stream: discussionStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text("");
        }
        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.data() == null) {
          return const Text('Something went wrong', style: TextConstants.titlePrimary);
        }
        Discussion discussion = snapshot.data!.data()!;
        return Slidable(
          key: const ValueKey(0),
          child: Container(
            color: Colors.transparent,
            child: ListTile(
              contentPadding: const EdgeInsets.all(0.0),
              title: Row(
                children: [
                  discussion.getDiscussionCircleAvatar(),
                  Expanded(child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        discussion.getTitleTextWidget(),
                        StreamBuilder<QuerySnapshot<Message>>(
                          stream: discussion.getLastMessageStream(),
                          builder: (context, snapshot) {
                            String content;
                            if(!snapshot.hasData || snapshot.connectionState == ConnectionState.waiting || snapshot.data!.docs.isEmpty){
                              content = "Loading...";
                            }
                            else{
                              Message lastm = snapshot.data!.docs[0].data();
                              content = lastm.messageContent;
                            }
                            return Text(content, style: TextConstants.defaultPrimary,);
                          }
                        ),
                      ],
                    ),
                  )),
                  StreamBuilder<QuerySnapshot<Message>>(
                      stream: discussion.getAllMessagesStream(),
                      builder: (context, snapshot) {
                        String userId = FirebaseAuth.instance.currentUser!.uid;
                        if(!snapshot.hasData){
                          return Row();
                        }
                        return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                            stream: Discussion.getDiscussionReference(discussion.discussion_id).collection("lastMessageSeenByUsers").doc(userId).snapshots(),
                            builder: (context, snapshotLastSeen) {
                              int unseennumber = 0;
                              if(!snapshotLastSeen.hasData){
                                unseennumber = 0;
                              }
                              else{
                                Map<String, dynamic> map = snapshotLastSeen.data!.data() ?? {};
                                if (map.isNotEmpty){
                                  String msgId = map["messageId"];
                                  unseennumber = snapshot.data!.docs.length;
                                  for(int i = 0; i<snapshot.data!.docs.length; i++){
                                    if(snapshot.data!.docs[i].data().messageId == msgId){
                                      unseennumber = i;
                                      break;
                                    }
                                  }
                                }
                              }
                              return unseennumber > 0 ? Container(
                                padding: const EdgeInsets.only(left: 5, right: 5),
                                decoration: const BoxDecoration(
                                    color: ColorConstants.backgroundHighlight,
                                    borderRadius: BorderRadius.all(Radius.circular(20))
                                ),
                                child: Text(unseennumber.toString(),
                                  style: TextConstants.defaultPrimary,),
                              ): Row();
                            });
                      }
                  ),
                ],
              ),
              onTap: ()=>{
                Navigator.push(context, MaterialPageRoute(builder: (context) => ChatRoom(discussionId: discussionId)))
              },
            ),
          ),
          endActionPane: ActionPane(
            motion: const BehindMotion(),
            // dismissible: DismissiblePane(onDismissed: () {}),

            // All actions are defined in the children parameter.
            children: [
              // A SlidableAction can have an icon and/or a label.
              SlidableAction(
                onPressed: (context) async {
                  await discussion.isDiscussionMutedForCurrentUser().then((value) async {
                    final scaffold = ScaffoldMessenger.of(context);
                    if (!muteIcons.containsKey(discussionId)){
                      muteIcons[discussionId] = false;
                    }
                    if (value) {
                      scaffold.showSnackBar(
                        SnackBar(
                          content: const Text('Discussion unmuted'),
                          action: SnackBarAction(label: 'OK', onPressed: scaffold.hideCurrentSnackBar),
                        ),
                      );
                      muteIcons[discussionId] = false;
                      await discussion.unmuteDiscussionForCurrentUser();
                    } else {
                      scaffold.showSnackBar(
                        SnackBar(
                          content: const Text('Discussion muted'),
                          action: SnackBarAction(label: 'OK', onPressed: scaffold.hideCurrentSnackBar),
                        ),
                      );
                      muteIcons[discussionId] = true;
                      await discussion.muteDiscussionForCurrentUser();
                    }
                  });
                },
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                icon: getIcon(discussionId),
                label: 'Mute',
              ),
              SlidableAction(
                onPressed: (context) {
                  discussion.removeDiscussionFromCurrentUserList();
                },
                backgroundColor: Color(0xFFFE4A49),
                foregroundColor: Colors.white,
                icon: Icons.delete,
                label: 'Delete',
              ),
            ],
          ),
        );
      }
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
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return const Text('Something went wrong', style: TextConstants.titlePrimary);
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