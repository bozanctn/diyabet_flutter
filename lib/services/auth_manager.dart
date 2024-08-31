import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthManager {
  static final AuthManager _instance = AuthManager._internal();

  factory AuthManager() {
    return _instance;
  }

  AuthManager._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<bool> checkIfSignedIn() async {
    return _auth.currentUser != null;
  }

  Future<bool> checkIfFirstSigned() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await _firestore.collection('Users').doc(user.uid).get();
      return userDoc.exists && userDoc.get('first') == true;
    }
    return false;
  }

  Future<void> logOut() async {
    await _auth.signOut();
  }
}
