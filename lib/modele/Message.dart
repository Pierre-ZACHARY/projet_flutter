


import 'package:cloud_firestore/cloud_firestore.dart';

class Message{

  final String messageId;
  final String discussionId;
  final String userId;
  final int type; // 0 = message classique, 1 = image, 2 = stickers, 3 = message informatif ( X a rejoint la discussion, Y a ajouté X à la discussion ... )
  final String messageContent;
  final String? imgUrl; // si le message contient une image
  final String? stickerId; // id du sticker choisit
  final Timestamp sendDatetime; // moment où le message a été envoyé

  Message({required this.discussionId, required this.userId, required this.messageId, required this.type, required this.messageContent, required this.sendDatetime, this.imgUrl, this.stickerId});
  Message.fromJson(Map<String, Object?> json) : this(
      messageId: json['messageId']! as String,
      discussionId: json['discussionId']! as String,
      userId: json['userId']! as String,
      type: json['type']! as int,
      messageContent: json['messageContent']! as String,
      imgUrl: json['imgUrl'] as String?,
      stickerId: json['stickerId'] as String?,
      sendDatetime: json['sendDatetime']! as Timestamp,
  );
  Map<String, Object?> toJson() {
    return {
      'messageId': messageId,
      'discussionId': discussionId,
      'userId': userId,
      'type': type,
      'messageContent': messageContent,
      'imgUrl': imgUrl,
      'stickerId': stickerId,
      'sendDatetime': sendDatetime,
    };
  }

  static Message? newMessage({required String discussionId, required String userId, required int type, required String messageContent, String? imgUrl, String? stickerId}){
    CollectionReference ref = firestoreCollectionReference();
    String messageId = ref.doc().id;
    Message newM = Message(sendDatetime: Timestamp.now(), userId: userId, messageId: messageId, discussionId: discussionId, type: type, messageContent: messageContent, imgUrl: imgUrl, stickerId: stickerId);
    ref.doc(messageId).set(
      newM.toJson()
    ).then((value) => print("Message Added"))
      .catchError((error) => {
        print("Failed to set message: $error")
        // TODO faire qlq chose si echec ( jsp )
      });
    return newM;
  }

  static CollectionReference firestoreCollectionReference(){
    return FirebaseFirestore.instance.collection('messages');
  }

  static DocumentReference<Message> getMessageReference(String messageId){
    CollectionReference discussionRef = firestoreCollectionReference();
    DocumentReference<Message> ref = discussionRef.doc(messageId).withConverter<Message>(
      fromFirestore: (snapshot, _) => Message.fromJson(snapshot.data()!),
      toFirestore: (discussion, _) => discussion.toJson(),
    );
    return ref;
  }

  static Stream<DocumentSnapshot<Message>> getMessageStream(String messageId){
    return firestoreCollectionReference().doc(messageId).withConverter<Message>(
      fromFirestore: (snapshot, _) => Message.fromJson(snapshot.data()!),
      toFirestore: (message, _) => message.toJson(),
    ).snapshots();
  }


}