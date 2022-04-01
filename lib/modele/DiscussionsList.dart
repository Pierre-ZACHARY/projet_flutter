import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class DiscussionsList{
  // chaque utilisateur possède une liste de discussion
  static const String collectionRef = 'discussionsList';
  static CollectionReference discussionsListRef() {
    return FirebaseFirestore.instance.collection(collectionRef);
  }

  final String uid;
  final List<dynamic> discussionsIds;
  final List<dynamic> mutedDiscussionIds;
  DiscussionsList({required this.uid, required this.discussionsIds, required this.mutedDiscussionIds});

  DiscussionsList.fromJson(Map<String, Object?> json) : this(
      uid: json['uid']! as String,
      discussionsIds: json['discussionsIds']! as List<dynamic>,
      mutedDiscussionIds: (json['mutedDiscussionIds'] ?? []) as List<dynamic>
  );
  Map<String, Object?> toJson() {
    return {
      'uid': uid,
      'discussionsIds': discussionsIds,
      'mutedDiscussionIds' : mutedDiscussionIds
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

  
  Future<void> muteDiscussion(String discussionId) async{
    DocumentReference<DiscussionsList> ref = getDiscussionListReference(uid);
    FirebaseFirestore.instance.runTransaction((transaction) async {
      DocumentSnapshot<DiscussionsList> freshSnap = await transaction.get(ref);
      DiscussionsList freshData = freshSnap.data()!;
      if(!freshData.mutedDiscussionIds.contains(discussionId)){
        freshData.mutedDiscussionIds.add(discussionId);
      }
      transaction.update(freshSnap.reference, freshData.toJson());
    });
    await FirebaseMessaging.instance.unsubscribeFromTopic(discussionId);
  }

  Future<void> unmuteDiscussion(String discussionId) async{
    DocumentReference<DiscussionsList> ref = getDiscussionListReference(uid);
    FirebaseFirestore.instance.runTransaction((transaction) async {
      DocumentSnapshot<DiscussionsList> freshSnap = await transaction.get(ref);
      DiscussionsList freshData = freshSnap.data()!;
      if(freshData.mutedDiscussionIds.contains(discussionId)){
        freshData.mutedDiscussionIds.remove(discussionId);
      }
      transaction.update(freshSnap.reference, freshData.toJson());
    });
    await FirebaseMessaging.instance.subscribeToTopic(discussionId);
  }

  bool isDiscussionMuted(String discussionId){
    return mutedDiscussionIds.contains(discussionId);
  }
}
