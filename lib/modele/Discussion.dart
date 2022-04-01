import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobx/mobx.dart';
import 'package:projet_flutter/app/home/chats/chat_room.dart';
import 'package:projet_flutter/main.dart';
import 'package:projet_flutter/modele/DiscussionsList.dart';
import 'package:projet_flutter/modele/Message.dart';
import 'package:projet_flutter/modele/UserInfo.dart';
import 'package:projet_flutter/utils/constant.dart';

import '../utils/cloudStorageUtils.dart';

class Discussion {
  // correspond à une discussion entre deux ou plusieurs utilisateurs
  final String discussion_id;
  //final List<dynamic> messagesIds; // trié par plus récent : les messages en début de liste sont ceux qui viennent d'arriver
  final List<dynamic> usersIds;
  final Map<dynamic, dynamic> lastMessageSeenByUsers;
  final int type; // 0 = discussion entre 2 utilisateurs, 1 = discussion de groupe
  final String? imgUrl; // image du groupe si type 1
  final String? groupTitle; // titre du groupe si type 1

  Discussion({
    required this.imgUrl,
    required this.groupTitle ,
    required this.discussion_id,
    required this.type,
    required this.lastMessageSeenByUsers,
    required this.usersIds
  });
  Discussion.fromJson(Map<String, Object?> json) : this(
      discussion_id: json['discussion_id']! as String,
      usersIds: json['usersIds']! as List<dynamic>,
      type: json['type']! as int,
      lastMessageSeenByUsers: (json['lastMessageSeenByUsers'] ?? {}) as Map<dynamic, dynamic>,
      groupTitle: json['groupTitle'] as String?,
      imgUrl: json['imgUrl'] as String?,
  );
  Map<String, Object?> toJson() {
    return {
      'discussion_id': discussion_id,
      'usersIds': usersIds,
      'type': type,
      'lastMessageSeenByUsers': lastMessageSeenByUsers,
      'groupTitle': groupTitle,
      'imgUrl': imgUrl,
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
        DiscussionsList newDiscussionList = DiscussionsList(uid: userid, discussionsIds: [discussion_id], mutedDiscussionIds: []);
        CollectionReference discussionListref = DiscussionsList.discussionsListRef();
        discussionListref.doc(userid).set(newDiscussionList.toJson())
            .then((value) => print("discussionList created"))
            .catchError((error) => print("Failed to create discussionList: $error"));
      }
    }
  }

  Future<void> sendMessageFromCurrentUser(String messageContent, {int type=0} ) async {
    DocumentReference<Discussion> ref = getDiscussionReference(discussion_id);
    String userId = FirebaseAuth.instance.currentUser!.uid;
    await Message.newMessage(userId: userId, discussionId: discussion_id, type: 0, messageContent: messageContent);
    await setDiscussionInFirstPosition();
  }

  Future<void> sendImageFromCurrentUser(File imageFile) async{
    String userid = FirebaseAuth.instance.currentUser!.uid;
    await Message.newMessage(userId: userid, discussionId: discussion_id, type: 1, messageContent: "Contient image", image: imageFile);
    await setDiscussionInFirstPosition();
  }

  void sendStickersFromCurrentUser(String StickersIds){
    // TODO ( c'est un peu comme la fonction send image sauf que on upload pas d'image, le stickers est stocké dans les assets de l'application, il faut juste indiquer lequel on envoi )
  }

  @action
  void updateLastMessageSeenForCurrentUser(String messageId){
    // TODO mettre ça dans une collection à part
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

  Stream<QuerySnapshot<Message>> getLastMessageStream(){
    return Message.firestoreCollectionReference()
        .where('discussionId', isEqualTo: discussion_id)
        .orderBy('sendDatetime', descending: true)
        .limit(1)
        .withConverter<Message>(
      fromFirestore: (snapshot, _) => Message.fromJson(snapshot.data()!),
      toFirestore: (discussion, _) => discussion.toJson(),
    ).snapshots();
  }


  Stream<QuerySnapshot<Message>> getAllMessagesStream(){
    return Message.firestoreCollectionReference()
        .where('discussionId', isEqualTo: discussion_id)
        .orderBy('sendDatetime', descending: true)
        .withConverter<Message>(
      fromFirestore: (snapshot, _) => Message.fromJson(snapshot.data()!),
      toFirestore: (discussion, _) => discussion.toJson(),
    ).snapshots();
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
              return const Text("", style: TextConstants.titlePrimary);
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
      return CircleAvatar(
        backgroundColor: Colors.white,
        backgroundImage: const AssetImage('assets/images/default-profile-picture.png'),
        foregroundImage: imgUrl != null ? NetworkImage(imgUrl!) : null,
      );
    }

  }

  Widget getTitleTextWidget(){
    //renvoi le titre de la discussion

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
          return const Text("");
        }
        if (snapshot.hasError || !snapshot.hasData ||
            snapshot.data!.data() == null) {
          return const Text('Something went wrong', style: TextConstants.titlePrimary);
        }
        Userinfo otherUserInfo = snapshot.data!.data()!;
        String titre;
        if(type == 0) {
          titre = otherUserInfo.displayName;
        }
        else{
          titre = groupTitle ?? "Group Discussion";
        }
        return Text(titre, style: TextConstants.titlePrimary,);
      });

  }

  Future<void> addUser(BuildContext context, String userId) async{
    if(type==0){
      List newUsersIds = usersIds;
      newUsersIds.add(userId);
      String discussionId = await openDiscussion(newUsersIds);
      Userinfo uinfo = await Userinfo.getUserSnapshotById(userId);
      Discussion newDisc = await getDiscussionSnapshotById(discussionId);
      newDisc.sendMessageFromCurrentUser("a ajouté "+uinfo.displayName+" au groupe", type: 3);
      Navigator.push(context, MaterialPageRoute(builder: (context) => ChatRoom(discussionId: discussionId)));
    }
    else{
      // si c'est déjà une discussion de groupe, pas besoin d'en créer une nouvelle
      DocumentReference<Discussion> ref = getDiscussionReference(discussion_id);
      FirebaseFirestore.instance.runTransaction((transaction) async {
        DocumentSnapshot<Discussion> freshSnap = await transaction.get(ref);
        List<dynamic> newusersIds = freshSnap.data()!.usersIds;
        if(!newusersIds.contains(userId)) {
          newusersIds.add(userId);
          Userinfo uinfo = await Userinfo.getUserSnapshotById(userId);
          sendMessageFromCurrentUser("a ajouté "+uinfo.displayName+" au groupe", type: 3);
        }
        transaction.update(freshSnap.reference, {
          'usersIds': newusersIds,
        });
      });
    }
  }

  Future<void> changeImage(File imageFile) async{
    DocumentReference<Discussion> ref = getDiscussionReference(discussion_id);
    sendMessageFromCurrentUser("a modifié l'image du groupe", type: 3);
    FirebaseFirestore.instance.runTransaction((transaction) async {
      DocumentSnapshot<Discussion> freshSnap = await transaction.get(ref);
      transaction.update(freshSnap.reference, {
        'imgUrl': imgUrl,
      });
    });
  }

  Future<void> changeTitle(String newTitle) async{
    DocumentReference<Discussion> ref = getDiscussionReference(discussion_id);
    sendMessageFromCurrentUser("a modifié le nom du groupe en : "+newTitle, type: 3);
    FirebaseFirestore.instance.runTransaction((transaction) async {
      DocumentSnapshot<Discussion> freshSnap = await transaction.get(ref);
      transaction.update(freshSnap.reference, {
        'groupTitle': newTitle,
      });
    });
  }

  Future<void> removeDiscussionFromCurrentUserList() async{
    DiscussionsList discussionsList = await DiscussionsList.getDiscussionListSnapshotById(FirebaseAuth.instance.currentUser!.uid);
    await discussionsList.removeDiscussion(discussion_id);
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

  static Future<Discussion> getDiscussionSnapshotById(String discId) async {
    DocumentReference<Discussion> discRef = await getDiscussionReference(discId);
    DocumentSnapshot<Discussion> snapshot = await discRef.get();
    Discussion uinfo = snapshot.data()!;
    return uinfo;
  }

  static Future<String> openDiscussion(List<dynamic> usersIds) async {
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
      }
      discussion = Discussion(
          discussion_id: discussionId, usersIds: usersIds, type: type, lastMessageSeenByUsers: {}, imgUrl: null, groupTitle: null);
      discussionRef.doc(discussionId).set(discussion.toJson())
          .then((value) => print("discussion open"))
          .catchError((error) => print("Failed to open discussion: $error"));
    }
    // enfin, on add la discussion à tous les utilisateurs
    await discussion.setDiscussionInFirstPosition();
    return discussionId;
  }


  Future<void> muteDiscussionForCurrentUser() async{
    DiscussionsList userDiscussionList = await DiscussionsList.getDiscussionListSnapshotById(FirebaseAuth.instance.currentUser!.uid);
    await userDiscussionList.muteDiscussion(discussion_id);
  }

  Future<void> unmuteDiscussionForCurrentUser() async{
    DiscussionsList userDiscussionList = await DiscussionsList.getDiscussionListSnapshotById(FirebaseAuth.instance.currentUser!.uid);
    await userDiscussionList.unmuteDiscussion(discussion_id);
  }

  Future<bool> isDiscussionMutedForCurrentUser() async{
    DiscussionsList userDiscussionList = await DiscussionsList.getDiscussionListSnapshotById(FirebaseAuth.instance.currentUser!.uid);
    return userDiscussionList.isDiscussionMuted(discussion_id);
  }

  Future<void> typingEventFromCurrentUser() async{
    String userId = FirebaseAuth.instance.currentUser!.uid;
    await getDiscussionReference(discussion_id).collection("lastTypingEventByUsers").doc(userId).set({"lastType": Timestamp.now()});
  }

  Future<void> stopTypingFromCurrentUser() async{
    String userId = FirebaseAuth.instance.currentUser!.uid;
    await getDiscussionReference(discussion_id).collection("lastTypingEventByUsers").doc(userId).set({"lastType": null});
  }
}