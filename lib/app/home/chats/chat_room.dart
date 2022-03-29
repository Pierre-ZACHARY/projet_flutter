

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
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

  @override
  void initState() {
    super.initState();
  }

  Future<void> sendMsg() async{
    String text = sendMessageController.text;
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
      DocumentReference<Discussion> ref = Discussion.getDiscussionReference(widget.discussionId);
      DocumentSnapshot<Discussion> snapshot = await ref.get();
      Discussion discussion = snapshot.data()!;
      await discussion.sendImageFromCurrentUser(File(image.path));
    }
  }

  Widget _buildMessageTile(BuildContext context, String messageId){
    Stream<DocumentSnapshot<Message>> stream = Message.getMessageStream(messageId);
    return StreamBuilder<DocumentSnapshot<Message>>(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.data() == null) {
          return const Text('Something went wrong', style: TextConstants.defaultPrimary);
        }
        Message msg = snapshot.data!.data()!;
        Stream<DocumentSnapshot<Userinfo>> userinfoStream = Userinfo.getUserDocumentStream(msg.userId);
        return StreamBuilder<DocumentSnapshot<Userinfo>>(
          stream: userinfoStream,
          builder: (context, UserinfoSnapshot) {
            if (UserinfoSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (UserinfoSnapshot.hasError || !UserinfoSnapshot.hasData || UserinfoSnapshot.data!.data() == null) {
              return const Text('Something went wrong', style: TextConstants.defaultPrimary);
            }
            Userinfo userinfo = UserinfoSnapshot.data!.data()!;
            bool isCurrentUser = userinfo.uid == FirebaseAuth.instance.currentUser!.uid;

            // TODO on veut pouvoir edit ( si c'est du text donc type = 0 ) / delete un message ( en restant appuyer dessus ça ouvre un menu deroulant par exemple ? )
            return ListTile(
              contentPadding: EdgeInsets.all(0),
              // TODO mettre en subtitle les personnes qui ont vu les messages dans la liste "lastMessageSeen" de discussion
              //subtitle: Text(""),
              title: Row(
                mainAxisAlignment: isCurrentUser ? MainAxisAlignment.end : MainAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.all(2.0),
                    decoration: BoxDecoration(
                      color: (!isCurrentUser ? ColorConstants.backgroundHighlight : ColorConstants.primaryHighlight),
                      borderRadius: const BorderRadius.all(Radius.circular(20))
                    ),
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
                                    Text(userinfo.displayName, style: !isCurrentUser ? TextConstants.hintPrimary : TextConstants.hintSecondary),
                                    msg.type == 0 ? Text(msg.messageContent, style: !isCurrentUser ? TextConstants.defaultPrimary : TextConstants.defaultSecondary) : Row(),
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
                              image:NetworkImage(msg.imgUrl!)),
                        ) : Row(),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    final stream = Discussion.getDiscussionStream(widget.discussionId);
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: StreamBuilder<DocumentSnapshot<Discussion>>(
          stream: stream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError || !snapshot.hasData || snapshot.data!.data() == null) {
              return const Text('Something went wrong', style: TextConstants.titlePrimary);
            }

            Discussion discussion = snapshot.data!.data()!;
            return Scaffold(
              backgroundColor: ColorConstants.background,
              appBar: AppBar(
                backgroundColor: ColorConstants.backgroundHighlight,
                title: Row(
                  children: [
                    discussion.getDiscussionCircleAvatar(),
                    Expanded(child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: discussion.getTitleTextWidget(),
                    ))
                    // TODO logo param qui envoie sur vue pour param la discussion : changer son nom / ajouter un utilisateur ( voir comment j'ai fait la recherche d'utilisateur dans chat_page )
                  ],
                ),
              ),
              body: Column(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          child: ListView.builder(
                            scrollDirection: Axis.vertical,
                            reverse: true,
                            itemCount: discussion.messagesIds.length,
                            itemBuilder: (context, index) => _buildMessageTile(context, discussion.messagesIds[index]),
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
                              decoration: InputDecoration(
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
            );
          }
        ),
    );
  }

}