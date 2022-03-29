import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:projet_flutter/main.dart';
import 'package:projet_flutter/modele/DiscussionsList.dart';
import 'package:projet_flutter/modele/Message.dart';
import 'package:projet_flutter/modele/UserInfo.dart';
import 'package:projet_flutter/utils/constant.dart';

import '../utils/cloudStorageUtils.dart';

class Discussion {
  // correspond à une discussion entre deux ou plusieurs utilisateurs
  final String discussion_id;
  final List<dynamic> messagesIds; // trié par plus récent : les messages en début de liste sont ceux qui viennent d'arriver
  final List<dynamic> usersIds;
  final Map<dynamic, dynamic> lastMessageSeenByUsers;
  final int type; // 0 = discussion entre 2 utilisateurs, 1 = discussion de groupe

  Discussion({required this.discussion_id, required this.type, required this.lastMessageSeenByUsers, required this.messagesIds, required this.usersIds});
  Discussion.fromJson(Map<String, Object?> json) : this(
      discussion_id: json['discussion_id']! as String,
      messagesIds: json['messagesIds']! as List<dynamic>,
      usersIds: json['usersIds']! as List<dynamic>,
      type: json['type']! as int,
      lastMessageSeenByUsers: json['lastMessageSeenByUsers']! as Map<dynamic, dynamic>,
  );
  Map<String, Object?> toJson() {
    return {
      'discussion_id': discussion_id,
      'messagesIds': messagesIds,
      'usersIds': usersIds,
      'type': type,
      'lastMessageSeenByUsers': lastMessageSeenByUsers,
    };
  }

  Future<void> setDiscussionInFirstPosition() async{
    for(String userid in usersIds){
      Stream<DocumentSnapshot<DiscussionsList>> userDiscussions = DiscussionsList
          .getUserDiscussionsList(userid);
      DocumentSnapshot<DiscussionsList> discussionListSnapshot = await userDiscussions.first;
      if (discussionListSnapshot.data() != null) {
        DiscussionsList discussionList = discussionListSnapshot.data()!;
        discussionList.addDiscussion(discussion_id);
      }
      else{
        DiscussionsList newDiscussionList = DiscussionsList(uid: userid, discussionsIds: [discussion_id],);
        CollectionReference discussionListref = DiscussionsList.discussionsListRef();
        discussionListref.doc(userid).set(newDiscussionList.toJson())
            .then((value) => print("discussionList created"))
            .catchError((error) => print("Failed to create discussionList: $error"));
      }
    }
  }

  Future<void> sendMessageFromCurrentUser(String messageContent) async {
    DocumentReference<Discussion> ref = getDiscussionReference(discussion_id);
    String userId = FirebaseAuth.instance.currentUser!.uid;
    Message? msg = await Message.newMessage(userId: userId, discussionId: discussion_id, type: 0, messageContent: messageContent);
    FirebaseFirestore.instance.runTransaction((transaction) async {
      DocumentSnapshot<Discussion> freshSnap = await transaction.get(ref);
      List<dynamic> messagesIds = freshSnap.data()!.messagesIds;
      messagesIds.insert(0, msg!.messageId);
      transaction.update(freshSnap.reference, {
        'messagesIds': messagesIds,
      });
    });
    await setDiscussionInFirstPosition();
    // TODO send push notif
  }

  Future<void> sendImageFromCurrentUser(File imageFile) async{
    String userid = FirebaseAuth.instance.currentUser!.uid;
    DocumentReference<Discussion> ref = getDiscussionReference(discussion_id);
    Message? msg = await Message.newMessage(userId: userid, discussionId: discussion_id, type: 1, messageContent: "Contient image", image: imageFile);
    FirebaseFirestore.instance.runTransaction((transaction) async {
      DocumentSnapshot<Discussion> freshSnap = await transaction.get(ref);
      List<dynamic> messagesIds = freshSnap.data()!.messagesIds;
      messagesIds.insert(0, msg!.messageId);
      transaction.update(freshSnap.reference, {
        'messagesIds': messagesIds,
      });
    });
    await setDiscussionInFirstPosition();
    // TODO send push notif
  }

  void sendStickersFromCurrentUser(String StickersIds){
    // TODO ( c'est un peu comme la fonction send image sauf que on upload pas d'image, le stickers est stocké dans les assets de l'application, il faut juste indiquer lequel on envoi )
  }

  void updateLastMessageSeenForCurrentUser(String messageId){
    DocumentReference<Discussion> ref = getDiscussionReference(discussion_id);
    String userId = FirebaseAuth.instance.currentUser!.uid;
    FirebaseFirestore.instance.runTransaction((transaction) async {
      DocumentSnapshot<Discussion> freshSnap = await transaction.get(ref);
      Map<dynamic, dynamic> localLastMessageSeenByUsers = freshSnap.data()!.lastMessageSeenByUsers;
      localLastMessageSeenByUsers[userId] = messageId;
      transaction.update(freshSnap.reference, {
        'lastMessageSeenByUsers': localLastMessageSeenByUsers,
      });
    });
  }

  int numberOfUnseenMessagesForCurrentUser() {
    String userId = FirebaseAuth.instance.currentUser!.uid;
    String? msgId = lastMessageSeenByUsers[userId];
    if(msgId == null){
      // si y'en a pas : il n'a jamais ouvert la discu
      return messagesIds.length;
    }
    return messagesIds.indexOf(msgId);
  }


  Widget getDiscussionCircleAvatar(){
    //renvoi le titre de la discussion
    if(usersIds.length == 2) {
      // le cas où c'est une conversation entre 2 utilisateurs : on veut afficher le pseudo / l'image de l'autre utilisateur
      String currentUid = FirebaseAuth.instance.currentUser!.uid;
      String otherUid = usersIds[0] == currentUid ? usersIds[1] : usersIds[0];
      Stream<DocumentSnapshot<Userinfo>> otherUserStream = Userinfo
          .getUserDocumentStream(otherUid);

      return StreamBuilder<DocumentSnapshot<Userinfo>>(
          stream: otherUserStream,
          builder: (context, snapshot)
          {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Text("Loading", style: TextConstants.titlePrimary);
            }
            if (snapshot.hasError || !snapshot.hasData ||
                snapshot.data!.data() == null) {
              return const Text('Something went wrong', style: TextConstants.titlePrimary);
            }

            Userinfo otherUserInfo = snapshot.data!.data()!;
            return CircleAvatar(
                  backgroundColor: Colors.white,
                  backgroundImage: const AssetImage('assets/images/default-profile-picture.png'),
                  foregroundImage: otherUserInfo.imgUrl != "" ? NetworkImage(otherUserInfo.imgUrl) : null,
                );
          });
    }
    else{
      // TODO le cas où c'est une conv de groupe on veut qu'elle ait une image de profile modifiable
      return const CircleAvatar(
                    backgroundColor: Colors.white,
                    backgroundImage: AssetImage('assets/images/default-profile-picture.png'),
                  );
    }

  }

  Widget getTitleTextWidget(){
    //renvoi le titre de la discussion
    if(usersIds.length == 2) {
      // le cas où c'est une conversation entre 2 utilisateurs : on veut afficher le pseudo / l'image de l'autre utilisateur
      String currentUid = FirebaseAuth.instance.currentUser!.uid;
      String otherUid = usersIds[0] == currentUid ? usersIds[1] : usersIds[0];
      Stream<DocumentSnapshot<Userinfo>> otherUserStream = Userinfo
          .getUserDocumentStream(otherUid);

      return StreamBuilder<DocumentSnapshot<Userinfo>>(
          stream: otherUserStream,
          builder: (context, snapshot)
      {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text("Loading", style: TextConstants.titlePrimary);
        }
        if (snapshot.hasError || !snapshot.hasData ||
            snapshot.data!.data() == null) {
          return const Text('Something went wrong', style: TextConstants.titlePrimary);
        }

        Userinfo otherUserInfo = snapshot.data!.data()!;
        return Text(otherUserInfo.displayName, style: TextConstants.defaultPrimary,);
      });
    }
    else{
      // TODO le cas où c'est une conv de groupe on veut qu'elle ait un titre modifiable
      return const Text("Titre");
    }

  }

  static CollectionReference firestoreCollectionReference(){
    return FirebaseFirestore.instance.collection('discussion');
  }

  static Stream<DocumentSnapshot<Discussion>> getDiscussionStream(String discussion_id){
    return firestoreCollectionReference().doc(discussion_id).withConverter<Discussion>(
      fromFirestore: (snapshot, _) => Discussion.fromJson(snapshot.data()!),
      toFirestore: (discussion, _) => discussion.toJson(),
    ).snapshots();
  }

  static DocumentReference<Discussion> getDiscussionReference(String discussion_id){
    CollectionReference discussionRef = firestoreCollectionReference();
    DocumentReference<Discussion> ref = discussionRef.doc(discussion_id).withConverter<Discussion>(
      fromFirestore: (snapshot, _) => Discussion.fromJson(snapshot.data()!),
      toFirestore: (discussion, _) => discussion.toJson(),
    );
    return ref;
  }

  static Future<void> openDiscussion(List<String> usersIds) async {
    // ouvre une nouvelle discussion entre les différents utilisateurs --> la place en première position de leur file si elle est déjà ouverte ( utile pour refresh )
    print(usersIds);
    CollectionReference discussionRef = firestoreCollectionReference();
    usersIds.sort(); // trie par ordre alphabetic d'id
    String discussionId = "";
    for (String uid in usersIds) {
      discussionId += uid;
    }
    Stream<DocumentSnapshot<Discussion>> discussionStream = getDiscussionStream(discussionId);
    DocumentSnapshot<Discussion> snapshot = await discussionStream.first;
    Discussion discussion;
    if (snapshot.data() != null) {
      print(snapshot.data());
      discussion = snapshot.data()!;
      Map<String, Object?> json = discussion.toJson();
      print(json);
      json['usersIds'] = usersIds;
      json['discussion_id'] = discussionId;
      discussionRef.doc(discussionId).set(json)
          .then((value) => print("discussion open"))
          .catchError((error) => print("Failed to open discussion: $error"));
    }
    else {
      // la discussion n'existe pas encore
      int type = 0;
      if(usersIds.length > 2){
        type = 1;
        // TODO Dans ce cas on peut vouloir attribuer un id aléatoire à la discussion, sinon ça voudrait qu'un même groupe d'utilisateurs ne peut créer qu'un seul groupe pour eux ( de plus l'id ne changera pas à l'ajout de nouveaux utilisateurs de toute façon )
      }
      discussion = Discussion(
          discussion_id: discussionId, messagesIds: [], usersIds: usersIds, type: type, lastMessageSeenByUsers: {});
      discussionRef.doc(discussionId).set(discussion.toJson())
          .then((value) => print("discussion open"))
          .catchError((error) => print("Failed to open discussion: $error"));
    }

    // enfin, on add la discussion à tous les utilisateurs
    await discussion.setDiscussionInFirstPosition();

  }

}