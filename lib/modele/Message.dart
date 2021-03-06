


import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:projet_flutter/modele/Discussion.dart';
import 'package:projet_flutter/utils/cloudStorageUtils.dart';

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

  static Future<Message?> newMessage({required String discussionId, required String userId, required int type, required String messageContent, String? stickerId, File? image}) async {
    CollectionReference ref = firestoreCollectionReference();
    String messageId = ref.doc().id;
    String imageUrl = "";
    if(image!=null && type==1){
      await CloudStorage.uploadFile(image, "imagesmessages/"+discussionId+"/"+messageId+".png");
      imageUrl = await FirebaseStorage.instance.ref("imagesmessages/"+discussionId+"/"+messageId+".png").getDownloadURL();
    }
    Message newM = Message(sendDatetime: Timestamp.now(), userId: userId, messageId: messageId, discussionId: discussionId, type: type, messageContent: messageContent, imgUrl: imageUrl, stickerId: stickerId);
    ref.doc(messageId).set(
      newM.toJson()
    ).then((value) => print("Message Added"))
      .catchError((error) => {
        print("Failed to set message: $error")
      });
    return newM;
  }

  Future<void> editMessage({required String messageContent})async {
    DocumentReference<Message> ref = getMessageReference(messageId);
    FirebaseFirestore.instance.runTransaction((transaction) async {
      DocumentSnapshot<Message> freshSnap = await transaction.get(ref);
      transaction.update(freshSnap.reference, {
        'messageContent': messageContent,
      });
    });
  }


  Future<void> deleteMessage() async {
    DocumentReference<Message> ref = getMessageReference(messageId);
    FirebaseFirestore.instance.runTransaction((transaction) async {
      DocumentSnapshot<Message> freshSnap = await transaction.get(ref);
      transaction.update(freshSnap.reference, {
        'type': 3,
        'messageContent': "<Message supprimé>",
      });
    });
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