import 'package:cloud_firestore/cloud_firestore.dart';

class DiscussionsList{
  // chaque utilisateur possède une liste de discussion
  static const String collectionRef = 'discussionsList';
  static CollectionReference discussionsListRef() {
    return FirebaseFirestore.instance.collection(collectionRef);
  }

  final String uid;
  final List<dynamic> discussionsIds;
  DiscussionsList({required this.uid, required this.discussionsIds});

  DiscussionsList.fromJson(Map<String, Object?> json) : this(uid: json['uid']! as String, discussionsIds: json['discussionsIds']! as List<dynamic> );
  Map<String, Object?> toJson() {
    return {
      'uid': uid,
      'discussionsIds': discussionsIds,
    };
  }


  static Stream<DocumentSnapshot<DiscussionsList>> getUserDiscussionsList(String uid){
    return discussionsListRef().doc(uid).withConverter<DiscussionsList>(
      fromFirestore: (snapshot, _) => DiscussionsList.fromJson(snapshot.data()!),
      toFirestore: (bandnames, _) => bandnames.toJson(),
    ).snapshots();
  }

  static DocumentReference<DiscussionsList> getDiscussionListReference(String uid){
    CollectionReference discussionRef = discussionsListRef();
    DocumentReference<DiscussionsList> ref = discussionRef.doc(uid).withConverter<DiscussionsList>(
      fromFirestore: (snapshot, _) => DiscussionsList.fromJson(snapshot.data()!),
      toFirestore: (discussion, _) => discussion.toJson(),
    );
    return ref;
  }

  static Future<DiscussionsList> getDiscussionListSnapshotById(String uid) async {
    DocumentReference<DiscussionsList> discRef = await getDiscussionListReference(uid);
    DocumentSnapshot<DiscussionsList> snapshot = await discRef.get();
    DiscussionsList discList = snapshot.data()!;
    return discList;
  }

  Future<void> addDiscussion(String discussionId){
    CollectionReference discussionsList = discussionsListRef();
    Map<String, Object?> json = toJson();
    List<dynamic> newList = discussionsIds;
    if(newList.contains(discussionId)){
      newList.remove(discussionId);
      newList.insert(0, discussionId);
    }
    else{
      newList.insert(0, discussionId);
    }
    json['discussionsIds'] = newList;
    return discussionsList
        .doc(uid)
        .set(json)
        .then((value) => print("discussion Added"))
        .catchError((error) => print("Failed to add discussion: $error"));
  }

  Future<void> removeDiscussion(String discussionId){
    CollectionReference discussionsList = discussionsListRef();
    // Call the user's CollectionReference to add a new user
    Map<String, Object?> json = toJson();
    List<dynamic> newList = discussionsIds;
    newList.remove(discussionId);
    json['discussionsIds'] = newList;
    return discussionsList
        .doc(uid)
        .set(json)
        .then((value) => print("discussion Added"))
        .catchError((error) => print("Failed to add discussion: $error"));
  }

}
