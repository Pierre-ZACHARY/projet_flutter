import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class CloudStorage{

  static const String profilePicturePath = "/usersProfilePictures/";

  static Future<void> uploadFile(File file, String path) async {
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

  static uploadUserProfilePicture(File profilePicture) async{
    if(FirebaseAuth.instance.currentUser == null){
      throw UserNotLoggedIn();
    }
    await uploadFile(profilePicture, profilePicturePath+FirebaseAuth.instance.currentUser!.uid+".png");
  }


  static Future<File> currentUserProfilePicture() async{
    if(FirebaseAuth.instance.currentUser == null){
      throw UserNotLoggedIn();
    }
    Directory appDocDir = await getApplicationDocumentsDirectory();
    String uid = FirebaseAuth.instance.currentUser!.uid;
    File res = File('${appDocDir.path}/profile_pictures/$uid.png');
    await downloadFile(res, profilePicturePath+FirebaseAuth.instance.currentUser!.uid+".png");
    return res;
  }
}

class UserNotLoggedIn implements Exception {
  @override
  String toString() {
    return "Can't get User informations because User isn't logged in";
  }
}