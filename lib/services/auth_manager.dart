import 'package:firebase_auth/firebase_auth.dart';

class AuthManager {
  static final AuthManager _instance = AuthManager._internal();

  factory AuthManager() {
    return _instance;
  }

  AuthManager._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<bool> checkIfSignedIn() async {
    return _auth.currentUser != null;
  }

  Future<void> logOut() async {
    await _auth.signOut();
  }
}