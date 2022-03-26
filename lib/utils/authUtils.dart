import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:projet_flutter/modele/UserInfo.dart';

class AuthUtils{


  static String? currentUserId() => FirebaseAuth.instance.currentUser?.uid;
  static final googleSignIn = GoogleSignIn();

  static Future<void> googleLogin() async {
    try {
      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) return;
      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithCredential(credential);
      User? user = userCredential.user;
      if (user != null && userCredential.additionalUserInfo != null) {
        if (userCredential.additionalUserInfo!.isNewUser) {
          Userinfo userInfo = Userinfo(
              active: true,
              uid: user.uid,
              imgUrl: user.photoURL ?? '',
              displayName: user.displayName ?? '');
          await userInfo.Update();
        }
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        throw UserNotFound();
      }
    }
  }

  static Future<void> Login(String email, String password, {Persistence? persistence}) async {
    try {
      if(persistence!= null){
        await FirebaseAuth.instance.setPersistence(persistence);
      }
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: password
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        throw UserNotFound();
      } else if (e.code == 'wrong-password') {
        throw WrongPassword();
      }
    }
  }

  static Future<void> Register(String email, String password, {Persistence? persistence, String? displayName}) async {
    try {
      if(persistence!= null){
        await FirebaseAuth.instance.setPersistence(persistence);
      }
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email,
          password: password
      );
      Userinfo userInfo = Userinfo(displayName: displayName ?? email.split("@").first, active: true, uid: userCredential.user!.uid, imgUrl: '', );
      await userInfo.Update();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        throw PasswordTooWeak();
      } else if (e.code == 'email-already-in-use') {
        throw EmailAlreadyInUse();
      }
    }
  }

  static Logout() async {
    String? provider = FirebaseAuth.instance.currentUser?.providerData[0].providerId;
    if (provider == "google.com") {
      await googleSignIn.disconnect();
    }
    await FirebaseAuth.instance.signOut();
  }
}


class EmailException implements Exception{

}

class PasswordException implements Exception{

}

class PasswordTooWeak extends PasswordException{
  @override
  String toString() {
    return 'The password provided is too weak.';
  }
}

class EmailAlreadyInUse extends EmailException{
  @override
  String toString() {
    return 'The account already exists for that email.';
  }
}

class UserNotFound extends EmailException{
  @override
  String toString() {
    return 'No user found for that email.';
  }
}

class WrongPassword extends PasswordException{
  @override
  String toString() {
    return 'Wrong password provided for that user.';
  }
}