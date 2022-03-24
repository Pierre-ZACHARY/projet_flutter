

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:projet_flutter/modele/Discussion.dart';
import 'package:projet_flutter/utils/constant.dart';


class ChatRoom extends StatefulWidget{
  final Stream<DocumentSnapshot<Discussion>> discussionStream;

  const ChatRoom({Key? key, required this.discussionStream}) : super(key: key);

  @override
  State<ChatRoom> createState() => _ChatRoomState();
}

class _ChatRoomState extends State<ChatRoom>{
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot<Discussion>>(
        stream: widget.discussionStream,
        builder: (context, snapshot) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: ColorConstants.backgroundHighlight,
              title: Row(
                  children:[
                CircleAvatar(
                  backgroundColor: Colors.white,
                  backgroundImage: AssetImage('assets/images/default-profile-picture.png'),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Expanded(child: Text("titre")),
                )]),
            ),
            body: Column(
                  children: [
                    const Expanded(
                      child: Center(
                        child: Text("dde"),
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            decoration: InputDecorationBuilder().addLabel("Message...").build(),
                          ),
                        ),
                      ],
                    )
                  ],


            ),
          );
        }
      );
  }

}