

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:projet_flutter/modele/Discussion.dart';
import 'package:projet_flutter/utils/constant.dart';

class ChatRoomParam extends StatefulWidget {

  final String discussionId;

  const ChatRoomParam({Key? key, required this.discussionId}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ChatRoomParamState();
}

class _ChatRoomParamState extends State<ChatRoomParam>{
  @override
  Widget build(BuildContext context) {

    return StreamBuilder<DocumentSnapshot<Discussion>>(
      stream: Discussion.getDiscussionStream(widget.discussionId),
      builder: (context, snapshot) {

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
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
                  padding: const EdgeInsets.all(8),
                  child: discussion.getTitleTextWidget(),
                )),
              ],
            ),
          ),
          body: const Center(child: Text("TODO")) // TODO
          // TODO On veut pouvoir : ajouter quelqu'un à la discussion, et si c'est une discussion de groupe : pouvoir modif son titre et sa photo
        );
      }
    );
  }

}