import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:projet_flutter/modele/Discussion.dart';
import 'package:projet_flutter/modele/UserInfo.dart';

class CloudStorage{

  static const String _profilePicturePath = "/usersProfilePictures/";
  static String? profilePictureUrl;

  static const String _discussionPicturePath = "/discussionPictures/";
  static String? discussionPictureUrl;

  static Future<void> uploadFile(File file, String path) async {
    print(path);
    SettableMetadata metadata = SettableMetadata(cacheControl: 'max-age=60');
    if(FirebaseAuth.instance.currentUser != null) {
      metadata.asMap().addAll({
          'userId': FirebaseAuth.instance.currentUser!.uid,
        }
      );
    }
    try {
      await FirebaseStorage.instance
          .ref(path)
          .putFile(file, metadata);
    } on FirebaseException catch (e) {
      // e.g, e.code == 'canceled'
    }
  }

  static Future<void> downloadFile(File downloadToFile, String path) async {
    try {
      await FirebaseStorage.instance
          .ref(path)
          .writeToFile(downloadToFile);
    } on FirebaseException catch (e) {
      // e.g, e.code == 'canceled'
    }
  }

  static Future<void> uploadUserProfilePicture(File profilePicture, Userinfo uinfo) async{
    if(FirebaseAuth.instance.currentUser == null){
      throw UserNotLoggedIn();
    }
    await uploadFile(profilePicture, _profilePicturePath+FirebaseAuth.instance.currentUser!.uid+".png");
    String url = await FirebaseStorage.instance.ref(_profilePicturePath+FirebaseAuth.instance.currentUser!.uid+".png").getDownloadURL();
    await uinfo.updateImgUrl(url);
  }

  static Future<void> uploadDiscussionPicture(File picture, Discussion disc) async{
    if(FirebaseAuth.instance.currentUser == null){
      throw UserNotLoggedIn();
    }
    await uploadFile(picture, _discussionPicturePath+disc.discussion_id+".png");
    String url = await FirebaseStorage.instance.ref(_discussionPicturePath+disc.discussion_id+".png").getDownloadURL();
    await disc.changeImage(url);
  }
}

class UserNotLoggedIn implements Exception {
  @override
  String toString() {
    return "Can't get User informations because User isn't logged in";
  }
}