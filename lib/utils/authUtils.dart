import 'package:firebase_auth/firebase_auth.dart';

class AuthUtils{

  static String? currentUserId() => FirebaseAuth.instance.currentUser?.uid;

  static Future<void> Login(String email, String password) async {
    try {
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

  static Future<void> Register(String email, String password) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email,
          password: password
      );
      FirebaseAuth.instance.currentUser?.updateDisplayName(email.split("@").first);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        throw PasswordTooWeak();
      } else if (e.code == 'email-already-in-use') {
        throw EmailAlreadyInUse();
      }
    }
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