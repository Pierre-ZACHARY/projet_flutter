import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:projet_flutter/modele/DiscussionsList.dart';

class Discussion {
  // correspond à une discussion entre deux ou plusieurs utilisateurs
  final String discussion_id;
  final List<String> messagesIds;
  final List<String> usersIds;

  Discussion({required this.discussion_id, required this.messagesIds, required this.usersIds});
  Discussion.fromJson(Map<String, Object?> json) : this(discussion_id: json['uid']! as String, messagesIds: json['messagesIds']! as List<String>, usersIds: json['usersIds']! as List<String> );
  Map<String, Object?> toJson() {
    return {
      'discussion_id': discussion_id,
      'messagesIds': messagesIds,
      'usersIds': usersIds,
    };
  }

  static Stream<DocumentSnapshot<Discussion>> getDiscussionStream(String discussion_id){
    return FirebaseFirestore.instance.collection('discussionsList').doc(discussion_id).withConverter<Discussion>(
      fromFirestore: (snapshot, _) => Discussion.fromJson(snapshot.data()!),
      toFirestore: (bandnames, _) => bandnames.toJson(),
    ).snapshots();
  }

  static Future<void> openDiscussion(List<String> usersIds) async {
    print(usersIds);
    CollectionReference discussion = FirebaseFirestore.instance.collection(
        'discussion');
    usersIds.sort(); // trie par ordre alphabetic d'id
    String discussionId = "";
    for (String uid in usersIds) {
      discussionId += uid;
    }
    // TODO on veut hash discussionId pour en réduire la taille ( une liste d'utilisateur = un id, toujours le même pour une même liste, mais pas besoin de pouvoir retrouver cette liste à partir de l'id )
    print(discussionId);
    Stream<DocumentSnapshot<Discussion>> discussionStream = getDiscussionStream(discussionId);
    print(discussionStream.length);
    DocumentSnapshot<Discussion> snapshot = await discussionStream.first;
    print(snapshot);
    print(snapshot.data());
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