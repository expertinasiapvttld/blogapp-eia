import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';

abstract class BaseAuth {
  Future<String> signUp(String email, String password);
  Future<User> getCurrentUser();
  Future<String> signIn(String email, String password);
}

class Auth implements BaseAuth {
  final FirebaseAuth firebaseAuth;

  Auth(this.firebaseAuth);
  // ignore: missing_return
  Future<String> signUp(String email, String password) async {
    try {
      UserCredential userCredential = await firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);
      return userCredential.user.uid;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        print('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        print('The account already exists for that email.');
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  // ignore: missing_return
  Future<User> getCurrentUser() async {
    User user = firebaseAuth.currentUser;
    if (user != null) {
      print(user.uid);
    }
    return user;


  }


  Future<String> signIn(String email, String password) async {
    try {
      UserCredential userCredential = await firebaseAuth
          .signInWithEmailAndPassword(
          email: email,
          password: password
      );
      return userCredential.user.uid;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        print('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        print('Wrong password provided for that user.');
      }
    }
  }


}
