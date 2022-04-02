import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobx/mobx.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:projet_flutter/app/home/chats/TypingIndicator.dart';
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

class Pair<String, Widget> {
  final String msgId;
  final Widget msgWidget;

  Pair(this.msgId, this.msgWidget);
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
      await discussion.stopTypingFromCurrentUser();
      await discussion.sendMessageFromCurrentUser(text);
      sendMessageController.text = "";
    }
  }

  Future<void> typeEvent(String value) async{
    DocumentReference<Discussion> ref = Discussion.getDiscussionReference(widget.discussionId);
    DocumentSnapshot<Discussion> snapshot = await ref.get();
    Discussion discussion = snapshot.data()!;
    if(value != ""){
      await discussion.typingEventFromCurrentUser();
    }
    else{
      await discussion.stopTypingFromCurrentUser();
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

  Map<String, Widget> lastSeenIndicatorWidgetByUserId = {};

  Widget _buildMessageTileContent(BuildContext context, Message msgTemp){
    Message msg = msgTemp;
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

          return StreamBuilder<DocumentSnapshot<Message>>(
            stream: Message.getMessageStream(msg.messageId),
            builder: (context, snapshot) {
              if(snapshot.hasData && snapshot.data!.data() !=null){
                msg = snapshot.data!.data()!;
              }
              return ListTile(
                  contentPadding: const EdgeInsets.all(0),
                  subtitle: Row(

                    children: [
                      Expanded(
                        child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                          stream: Discussion.getDiscussionReference(widget.discussionId)
                              .collection("lastMessageSeenByUsers")
                              .where("messageId", isEqualTo: msg.messageId)
                              .snapshots(),
                          builder: (context, snapshot) {
                            if(!snapshot.hasData || snapshot.hasError){
                              return Row();
                            }
                            List<QueryDocumentSnapshot<Map<String, dynamic>>> data = snapshot.data!.docs;
                            List<Widget> widgets = [];
                            for(QueryDocumentSnapshot<Map<String, dynamic>> entry in data){
                              if(!lastSeenIndicatorWidgetByUserId.containsKey(entry.id)){
                                lastSeenIndicatorWidgetByUserId[entry.id] = StreamBuilder<DocumentSnapshot<Userinfo>>(
                                    stream: Userinfo.getUserDocumentStream(entry.id),
                                    builder: (context, snapshot) {
                                      if(!snapshot.hasData || snapshot.hasError){
                                        return const Text("");
                                      }
                                      Userinfo u = snapshot.data!.data()!;

                                      Widget res = isCurrentUser ?  Padding(
                                        padding: const EdgeInsets.fromLTRB(0, 0, 8, 0),
                                        child: u.getCircleAvatar(radius: 10.0),
                                      ) : Padding(
                                        padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
                                        child: u.getCircleAvatar(radius: 10.0),
                                      );
                                      return res;
                                    }
                                );
                              }
                                widgets.add(lastSeenIndicatorWidgetByUserId[entry.id]!);
                              }

                            return Row(
                              mainAxisAlignment: isCurrentUser ? MainAxisAlignment.end : MainAxisAlignment.start,
                              children: widgets);
                          }
                        ),
                      ),
                    ],
                  ),
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
                                          msg.type == 0 || msg.type == 3 ? FittedBox(
                                            child: Container(
                                              constraints: BoxConstraints(
                                                maxWidth: (MediaQuery.of(context).size.width)/2,
                                              ),
                                              child: DefaultTextStyle(
                                                style: !isCurrentUser ? ( msg.type == 3 ?TextConstants.defaultPrimaryItalic :TextConstants.defaultPrimary) : (msg.type == 3 ? TextConstants.defaultSecondaryItalic : TextConstants.defaultSecondary),
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
        );
      }


  int _messageNumber = 20;
  int _totalMessages = -1;

  ScrollController _controller = ScrollController();


  List<Pair> savedWidgetInstance = [];

  Map<String, bool> typingUsers = {};
  Map<String, Timer> _typingUsersTimer = {};


  @override
  void initState() {
    super.initState();

    Discussion.getDiscussionReference(widget.discussionId).collection("lastTypingEventByUsers").snapshots().listen(( QuerySnapshot<Map<String, dynamic>> event) {

        bool changed = false;
        for(QueryDocumentSnapshot<Map<String, dynamic>> entry in event.docs){
          String userid = entry.id;
          Timestamp? timestamp = entry.data()["lastType"];
          if(timestamp == null && (typingUsers[userid] ?? true)){
            typingUsers[userid] = false;
            setState(() => {});
            changed = true;
          }
          else if( timestamp != null && Timestamp.now().seconds-timestamp.seconds<3) {
            typingUsers[userid] = true;
            if(_typingUsersTimer[userid] !=null && _typingUsersTimer[userid]!.isActive){
              _typingUsersTimer[userid]!.cancel();
            }
            else{
              changed = true;
            }
            _typingUsersTimer[userid] = Timer(const Duration(seconds: 3), () => {
            typingUsers[userid] = false,
            setState(() => {}),
            });
          }
        }

        if(changed){
          setState(() {
          });
        }


      }
    );

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

    discussionImageWidget = StreamBuilder<DocumentSnapshot<Discussion>>(
        stream: Discussion.getDiscussionStream(widget.discussionId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator(),);
          }
          Discussion disc = snapshot.data!.data()!;
          return disc.getDiscussionCircleAvatar() ;
        }
    );
    discussionTitleWidget = Expanded(child: Padding(
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
    )));
  }


  Widget discussionImageWidget = const Center(child: CircularProgressIndicator(),);
  Widget discussionTitleWidget = Expanded(child: Row(children: const [Center(child: CircularProgressIndicator()),],),);

  @override
  Widget build(BuildContext context) {

    List<Widget> typingIndicators = [];

    for(int i = 0; i < typingUsers.length; i++){
      typingIndicators.add(Center(child: TypingIndicator(userId: typingUsers.keys.elementAt(i), showIndicator: typingUsers[typingUsers.keys.elementAt(i)] ?? false)));
    }

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: Scaffold(
              backgroundColor: ColorConstants.background,
              appBar: AppBar(
                backgroundColor: ColorConstants.backgroundHighlight,
                title: Row(
                  children: [
                    discussionImageWidget,
                    discussionTitleWidget,
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

                            child: Column(
                              children: [
                                Expanded(
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

                                      if( snapshot.hasData && snapshot.data!.docs.isNotEmpty){
                                        setLastMessageSeen( snapshot.data!.docs[0].data().messageId);
                                        List<String> allIds = [];
                                        for(Pair p in savedWidgetInstance){
                                          allIds.add(p.msgId);
                                        }
                                        for(int i = 0; i<snapshot.data!.docs.length; i++){
                                          Message m = snapshot.data!.docs[i].data();
                                          if( i > savedWidgetInstance.length-1){
                                            savedWidgetInstance.add(Pair(m.messageId, _buildMessageTileContent(context, m)));
                                          }
                                          else if( !allIds.contains(m.messageId)) { // nouveau message
                                            savedWidgetInstance.insert(i, Pair(m.messageId, _buildMessageTileContent(context, m)));
                                          }
                                          if(m.messageId != savedWidgetInstance[i].msgId){
                                            print("id différent ? :" + m.messageId+ " / "+  savedWidgetInstance[i].msgId);
                                          }
                                        }
                                      }
                                      if (savedWidgetInstance.isEmpty) {
                                        return const Center(child: CircularProgressIndicator());
                                      }
                                      return ListView.builder(
                                        key: const PageStorageKey('const name here'),
                                        scrollDirection: Axis.vertical,
                                        reverse: true,
                                        controller: _controller,
                                        itemCount: savedWidgetInstance.length,
                                        itemBuilder: (context, index) {
                                            return savedWidgetInstance[index].msgWidget;
                                          },
                                      );
                                    }
                                  ),
                                ),

                                Center(
                                  child: Column(
                                    children: typingIndicators,
                                  ),
                                ),
                              ],
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
                              onChanged: (value) => typeEvent(value),
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
    print(_controller.position);
    if (_controller.offset >= _controller.position.maxScrollExtent &&
        !_controller.position.outOfRange) {
      _loadMore();
    }
  }
  void _loadMore() {
    WidgetsBinding.instance?.addPostFrameCallback((_){
      if(_messageNumber < _totalMessages){
        double pixels = _controller.position.pixels;
        print("avant set state");
        print(pixels);
        setState(() {
          _messageNumber += 10;
        });
      }
    });

  }
}