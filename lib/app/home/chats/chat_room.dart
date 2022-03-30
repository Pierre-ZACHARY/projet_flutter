import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobx/mobx.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:projet_flutter/app/home/chats/chat_room_param.dart';
import 'package:projet_flutter/app/home/chats/cupertino_options.dart';
import 'package:projet_flutter/modele/Discussion.dart';
import 'package:projet_flutter/modele/Message.dart';
import 'package:projet_flutter/modele/UserInfo.dart';
import 'package:projet_flutter/utils/constant.dart';


class ChatRoom extends StatefulWidget{
  final String discussionId;

  const ChatRoom({Key? key, required this.discussionId}) : super(key: key);


  @override
  State<ChatRoom> createState() => _ChatRoomState();
}

class _ChatRoomState extends State<ChatRoom>{
  TextEditingController sendMessageController = TextEditingController();
  TextEditingController editingController = TextEditingController();
  bool editing = false;

  Future<void> sendMsg() async{
    String text = sendMessageController.text;
    _messageNumber = 10;
    if(text.replaceAll(" ", "").isNotEmpty){
      DocumentReference<Discussion> ref = Discussion.getDiscussionReference(widget.discussionId);
      DocumentSnapshot<Discussion> snapshot = await ref.get();
      Discussion discussion = snapshot.data()!;
      await discussion.sendMessageFromCurrentUser(text);
      sendMessageController.text = "";
    }
  }

  Future<void> sendImg() async{
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if(image != null){
      _messageNumber = 10;
      DocumentReference<Discussion> ref = Discussion.getDiscussionReference(widget.discussionId);
      DocumentSnapshot<Discussion> snapshot = await ref.get();
      Discussion discussion = snapshot.data()!;
      await discussion.sendImageFromCurrentUser(File(image.path));
    }
  }

  Future<void> setLastMessageSeen(String id) async{
    DocumentReference<Discussion> ref = Discussion.getDiscussionReference(widget.discussionId);
    DocumentSnapshot<Discussion> snapshot = await ref.get();
    Discussion discussion = snapshot.data()!;
    discussion.updateLastMessageSeenForCurrentUser(id);
  }

  Widget _buildMessageTileContent(BuildContext context, Message msg){
    Stream<DocumentSnapshot<Userinfo>> userinfoStream = Userinfo.getUserDocumentStream(msg.userId);
    return StreamBuilder<DocumentSnapshot<Userinfo>>(
        stream: userinfoStream,
        builder: (context, UserinfoSnapshot) {
          if (UserinfoSnapshot.connectionState == ConnectionState.waiting) {
            return const Text("");
          }
          if (UserinfoSnapshot.hasError || !UserinfoSnapshot.hasData || UserinfoSnapshot.data!.data() == null) {
            return const Text('Something went wrong', style: TextConstants.defaultPrimary);
          }
          Userinfo userinfo = UserinfoSnapshot.data!.data()!;
          bool isCurrentUser = userinfo.uid == FirebaseAuth.instance.currentUser!.uid;

          return ListTile(
              contentPadding: const EdgeInsets.all(0),
              // TODO mettre en subtitle les personnes qui ont vu les messages dans la liste "lastMessageSeen" de discussion
              //subtitle: Text(""),
              title: CupertinoOptions(body: Row(
                mainAxisAlignment: isCurrentUser ? MainAxisAlignment.end : MainAxisAlignment.start,
                children: [
                  Container(
                    margin: EdgeInsets.all(2.0),
                    decoration: BoxDecoration(
                        color: (!isCurrentUser ? ColorConstants.backgroundHighlight : ColorConstants.primaryHighlight),
                        borderRadius: const BorderRadius.all(Radius.circular(20))
                    ),
                    child: FittedBox(
                      // fit: BoxFit.fitWidth,
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Row(
                              children: [
                                !isCurrentUser ? userinfo.getCircleAvatar() : const Text(""),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment: !isCurrentUser ? CrossAxisAlignment.start : CrossAxisAlignment.end,
                                    children: [
                                      DefaultTextStyle(
                                        style: !isCurrentUser ? TextConstants.hintPrimary : TextConstants.hintSecondary,
                                        child: Text(userinfo.displayName),
                                      ),
                                      msg.type == 0 ? FittedBox(
                                        child: Container(
                                          constraints: BoxConstraints(
                                            maxWidth: (MediaQuery.of(context).size.width)/2,
                                          ),
                                          child: DefaultTextStyle(
                                            style: !isCurrentUser ? TextConstants.defaultPrimary : TextConstants.defaultSecondary,
                                            child: Text(
                                              msg.messageContent,
                                            ),
                                          ),
                                        ),

                                      ) : Row(),
                                    ],
                                  ),
                                ),
                                isCurrentUser ? userinfo.getCircleAvatar() : const Text(""),
                              ],
                            ),
                          ),
                          msg.type == 1 ? ClipRRect(
                            borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20)),
                            child: Image(
                                width:(MediaQuery.of(context).size.width*1)/2,
                                image:NetworkImage(msg.imgUrl!)
                            ),
                          ) : Row(),
                        ],
                      ),
                    ),
                  ),
                ],
              ), message: msg, isCurrentUser: isCurrentUser),
            );
          }
        );
      }


  int _messageNumber = 20;
  int _totalMessages = -1;

  ScrollController _controller = ScrollController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(_scrollListener);

    //_controller.jumpTo(position?.pixels ?? 0);
    FirebaseFirestore.instance
        .collection('messages')
        .where('discussionId', isEqualTo: widget.discussionId)
        .get()
        .then((value) =>
        {
          _totalMessages = value.docs.length
        });
  }


  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: Scaffold(
              backgroundColor: ColorConstants.background,
              appBar: AppBar(
                backgroundColor: ColorConstants.backgroundHighlight,
                title: Row(
                  children: [
                    StreamBuilder<DocumentSnapshot<Discussion>>(
                      stream: Discussion.getDiscussionStream(widget.discussionId),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const Center(child: CircularProgressIndicator(),);
                        }
                        Discussion disc = snapshot.data!.data()!;
                        return disc.getDiscussionCircleAvatar() ;
                      }
                    ),
                    Expanded(child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: StreamBuilder<DocumentSnapshot<Discussion>>(
                          stream: Discussion.getDiscussionStream(widget.discussionId),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return const Text("Loading");
                            }
                            Discussion disc = snapshot.data!.data()!;
                            return disc.getTitleTextWidget() ;
                          }
                      ),
                    )),
                    IconButton(
                      icon: const Icon(Icons.settings),
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ChatRoomParam(discussionId: widget.discussionId))),

                    )
                  ],
                ),
              ),
              body: Column(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),

                            child: StreamBuilder<QuerySnapshot<Message>>(
                              stream: FirebaseFirestore.instance
                                  .collection('messages')
                                  .where('discussionId', isEqualTo: widget.discussionId)
                                  .orderBy('sendDatetime', descending: true)
                                  .limit(_messageNumber)
                                  .withConverter<Message>(
                                    fromFirestore: (snapshot, _) => Message.fromJson(snapshot.data()!),
                                    toFirestore: (discussion, _) => discussion.toJson(),
                                  )
                                  .snapshots(),
                              builder: (context, snapshot) {
                                if (!snapshot.hasData || snapshot.connectionState == ConnectionState.waiting) {
                                  return const Center(child: CircularProgressIndicator());
                                }
                                if( snapshot.data!.docs.isNotEmpty){
                                  setLastMessageSeen( snapshot.data!.docs[0].data().messageId);
                                }
                                return ListView.builder(
                                  key: const PageStorageKey('const name here'),
                                  scrollDirection: Axis.vertical,
                                  reverse: true,
                                  controller: _controller,
                                  itemCount: snapshot.data!.docs.length,
                                  itemBuilder: (context, index) {
                                      return _buildMessageTileContent(context, snapshot.data!.docs[index].data());
                                    },
                                );
                              }
                            ),
                          ),
                        ),

                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.image, color: ColorConstants.primary,),
                            onPressed: () => sendImg(),
                          ),
                          Expanded(
                            child: TextField(
                              controller: sendMessageController,
                              onEditingComplete:() => sendMsg(),
                              style: TextConstants.defaultPrimary,
                              decoration: const InputDecoration(
                                hintText: "Message...",
                                  hintStyle: TextConstants.defaultPrimary
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.send, color: ColorConstants.primary,),
                            onPressed: () => sendMsg(),
                          ),
                        ],
                      )
                    ],
              ),
            )
    );
  }

  _scrollListener() {
    if (_controller.offset >= _controller.position.maxScrollExtent &&
        !_controller.position.outOfRange) {
      _loadMore();
    }
  }
  void _loadMore() {
    WidgetsBinding.instance?.addPostFrameCallback((_){
      if(_messageNumber < _totalMessages){
        setState(() {
          _messageNumber += 10;
        });
      }
    });

  }
}