


import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';



class Userinfo{
  final String uid;
  final String displayName;
  final String imgUrl;
  final bool active;
  final bool notif;
  Userinfo({required this.uid, required this.displayName, required this.imgUrl, required this.active, required this.notif});


  Userinfo.fromJson(Map<String, Object?> json) : this(uid: json['uid']! as String, displayName: json['displayName']! as String, imgUrl: json['imgUrl']! as String, active: json['active']! as bool, notif: json['notif']! as bool );
  Map<String, Object?> toJson() {
    return {
      'uid': uid,
      'displayName': displayName,
      'imgUrl': imgUrl,
      'active': active,
      'notif': notif
    };
  }

  Widget getCircleAvatar(){
    return CircleAvatar(
      backgroundColor: Colors.white,
      backgroundImage: AssetImage('assets/images/default-profile-picture.png'),
      foregroundImage: NetworkImage(imgUrl),
    );
  }

  static Stream<DocumentSnapshot<Userinfo>> getUserDocumentStream(String uid){
    return FirebaseFirestore.instance.collection('users').doc(uid).withConverter<Userinfo>(
      fromFirestore: (snapshot, _) => Userinfo.fromJson(snapshot.data()!),
      toFirestore: (bandnames, _) => bandnames.toJson(),
    ).snapshots();
  }

  static Query<Userinfo> searchUser(String displayName){
    return FirebaseFirestore.instance
        .collection('users')
        .where('active', isEqualTo: true)
        .where('displayName', isGreaterThanOrEqualTo: displayName)
        .where('displayName', isLessThanOrEqualTo: displayName+ '\uf8ff')
        .withConverter<Userinfo>(
          fromFirestore: (snapshot, _) => Userinfo.fromJson(snapshot.data()!),
          toFirestore: (bandnames, _) => bandnames.toJson(),
        );
  }

  Future<void> Update() {
    CollectionReference users = FirebaseFirestore.instance.collection('users');
    // Call the user's CollectionReference to add a new user
    return users
        .doc(uid)
        .set(toJson())
        .then((value) => print("User Added"))
        .catchError((error) => print("Failed to add user: $error"));
  }

  Future<void> updateImgUrl(String url){
    CollectionReference users = FirebaseFirestore.instance.collection('users');
    // Call the user's CollectionReference to add a new user
    Map<String, Object?> json = toJson();
    json['imgUrl'] = url;
    return users
        .doc(uid)
        .set(json)
        .then((value) => print("User Added"))
        .catchError((error) => print("Failed to add user: $error"));
  }

  Future<void> updateDisplayName(String displayName){
    CollectionReference users = FirebaseFirestore.instance.collection('users');
    // Call the user's CollectionReference to add a new user
    Map<String, Object?> json = toJson();
    json['displayName'] = displayName;
    return users
        .doc(uid)
        .set(json)
        .then((value) => print("User found"))
        .catchError((error) => print("Failed to add user: $error"));
  }

  Future<void> updateActiveValue(bool active){
    CollectionReference users = FirebaseFirestore.instance.collection('users');
    // Call the user's CollectionReference to add a new user
    Map<String, Object?> json = toJson();
    json['active'] = active;
    return users
        .doc(uid)
        .set(json)
        .then((value) => print("User found"))
        .catchError((error) => print("Failed to add user: $error"));
  }
}