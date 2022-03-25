import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:projet_flutter/modele/DiscussionsList.dart';
import 'package:projet_flutter/modele/UserInfo.dart';
import 'package:projet_flutter/utils/constant.dart';

class Discussion {
  // correspond à une discussion entre deux ou plusieurs utilisateurs
  final String discussion_id;
  final List<dynamic> messagesIds;
  final List<dynamic> usersIds;

  Discussion({required this.discussion_id, required this.messagesIds, required this.usersIds});
  Discussion.fromJson(Map<String, Object?> json) : this(discussion_id: json['discussion_id']! as String, messagesIds: json['messagesIds']! as List<dynamic>, usersIds: json['usersIds']! as List<dynamic> );
  Map<String, Object?> toJson() {
    return {
      'discussion_id': discussion_id,
      'messagesIds': messagesIds,
      'usersIds': usersIds,
    };
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
      // TODO le cas où c'est une conv de groupe on veut qu'elle ait un titre modifiable
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

  static Stream<DocumentSnapshot<Discussion>> getDiscussionStream(String discussion_id){
    return FirebaseFirestore.instance.collection('discussion').doc(discussion_id).withConverter<Discussion>(
      fromFirestore: (snapshot, _) => Discussion.fromJson(snapshot.data()!),
      toFirestore: (bandnames, _) => bandnames.toJson(),
    ).snapshots();
  }

  static Future<void> openDiscussion(List<String> usersIds) async {
    // ouvre une nouvelle discussion entre les différents utilisateurs --> la place en première position de leur file si elle est déjà ouverte ( utile pour refresh )
    print(usersIds);
    CollectionReference discussion = FirebaseFirestore.instance.collection(
        'discussion');
    usersIds.sort(); // trie par ordre alphabetic d'id
    String discussionId = "";
    for (String uid in usersIds) {
      discussionId += uid;
    }
    // TODO on veut hash discussionId pour en réduire la taille ( une liste d'utilisateur = un id, toujours le même pour une même liste, mais pas besoin de pouvoir retrouver cette liste à partir de l'id )
    Stream<DocumentSnapshot<Discussion>> discussionStream = getDiscussionStream(discussionId);
    DocumentSnapshot<Discussion> snapshot = await discussionStream.first;
    if (snapshot.data() != null) {
      Map<String, Object?> json = snapshot.data()!.toJson();
      print(json);
      json['usersIds'] = usersIds;
      json['discussion_id'] = discussionId;
      discussion.doc(discussionId).set(json)
          .then((value) => print("discussion open"))
          .catchError((error) => print("Failed to open discussion: $error"));
    }
    else {
      // la discussion n'existe pas encore
      Discussion newDisc = Discussion(
          discussion_id: discussionId, messagesIds: [], usersIds: usersIds);
      discussion.doc(discussionId).set(newDisc.toJson())
          .then((value) => print("discussion open"))
          .catchError((error) => print("Failed to open discussion: $error"));
    }

    // enfin, on add la discussion à l'utilisateur courant
    Stream<DocumentSnapshot<DiscussionsList>> userDiscussions = DiscussionsList
        .getUserDiscussionsList(FirebaseAuth.instance.currentUser!.uid);
    DocumentSnapshot<DiscussionsList> discussionListSnapshot = await userDiscussions.first;
    if (discussionListSnapshot.data() != null) {
      DiscussionsList discussionList = discussionListSnapshot.data()!;
      discussionList.addDiscussion(discussionId);
    }
    else{
      DiscussionsList newDiscussionList = DiscussionsList(uid: FirebaseAuth.instance.currentUser!.uid, discussionsIds: [discussionId],);
      CollectionReference discussionListref = DiscussionsList.discussionsListRef();
      discussionListref.doc(FirebaseAuth.instance.currentUser!.uid).set(newDiscussionList.toJson())
          .then((value) => print("discussionList created"))
          .catchError((error) => print("Failed to create discussionList: $error"));
      // TODO /!\ ouvrir une discussion sur l'utilisateur courant ne l'ouvre pas forcement chez les autres utilisateurs : faire attention à ça quand envoi de messages
    }
  }

}