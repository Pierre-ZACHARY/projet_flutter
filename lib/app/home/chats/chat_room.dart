

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:projet_flutter/modele/Discussion.dart';
import 'package:projet_flutter/utils/constant.dart';


class ChatRoom extends StatefulWidget{
  final String discussionId;

  const ChatRoom({Key? key, required this.discussionId}) : super(key: key);

  @override
  State<ChatRoom> createState() => _ChatRoomState();
}

class _ChatRoomState extends State<ChatRoom>{
  @override
  Widget build(BuildContext context) {
    final stream = Discussion.getDiscussionStream(widget.discussionId);
    return StreamBuilder<DocumentSnapshot<Discussion>>(
        stream: stream,
        builder: (context, snapshot) {
          print(snapshot);
          print(widget.discussionId);
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Text("Loading", style: TextConstants.titlePrimary);
          }
          if (snapshot.hasError || !snapshot.hasData || snapshot.data!.data() == null) {
            return const Text('Something went wrong', style: TextConstants.titlePrimary);
          }

          Discussion discussion = snapshot.data!.data()!;
          return Scaffold(
            appBar: AppBar(
              backgroundColor: ColorConstants.backgroundHighlight,
              title: Row(
                children: [
                  discussion.getDiscussionCircleAvatar(),
                  Expanded(child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: discussion.getTitleTextWidget(),
                  ))
                ],
              ),
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