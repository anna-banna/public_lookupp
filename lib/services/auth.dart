import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../toast.dart';

class FirebaseAuthService {
  FirebaseAuth auth = FirebaseAuth.instance;

  Future<User?> signUpWithEmailAndPassword(
      String email, String password) async {
    try {
      UserCredential credential = await auth.createUserWithEmailAndPassword(
          email: email, password: password);
      return credential.user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        showToast(
            message: 'The email address is already in use.',
            backgroundColor: Colors.red);
      }
      if (e.code == 'weak-password') {
        showToast(
            message: 'The password provided is too weak.',
            backgroundColor: Colors.red);
      }
      // else {
      //   showToast(
      //       message: 'An error occurred: ${e.code}',
      //       backgroundColor: Colors.red);
      // }
    }
    return null;
  }

  Future<User?> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      UserCredential credential = await auth.signInWithEmailAndPassword(
          email: email, password: password);
      return credential.user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found' || e.code == 'wrong-password') {
        showToast(
            message: 'Invalid email or password.', backgroundColor: Colors.red);
      }
      // else {
      //   showToast(
      //       message: 'An error occurred: ${e.code}',
      //       backgroundColor: Colors.red);
      // }
    }
    return null;
  }
}
