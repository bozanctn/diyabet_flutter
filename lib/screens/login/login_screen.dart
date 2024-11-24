import 'dart:io' show Platform;
import 'package:diyabet/screens/login/profile_info.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sign_in_button/sign_in_button.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:diyabet/helper/loading_screen.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import '../tabbar.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  //final Uri _url = Uri.parse('http://www.linkmis.info.tr');
  final Uri _urldestek = Uri.parse('https://www.linkmis.info.tr/privacy-policy/');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              color: Color.fromRGBO(19, 69, 122, 1.0), // Dark blue background color
            ),
          ),
          Center(
            child: Container(
              padding: const EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 8.0,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    "Hoş Geldiniz!",
                    style: TextStyle(
                      color: Color(0xFF0D47A1),
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  SignInButton(
                    Buttons.google,
                    text: "Google ile Devam Et",
                    onPressed: _signInWithGoogle,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (Platform.isIOS)
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.8,
                      child: SignInWithAppleButton(
                        text: 'Apple İle Devam Et',
                        onPressed: _signInWithApple,
                      ),
                    ),
                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: _openSupportPage,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      backgroundColor: Color(0xFF0D47A1).withOpacity(0.8),
                    ),
                    child: const Text(
                      'Destek Alın',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 16,
            right: 16,
            child: FloatingActionButton(
              backgroundColor: Colors.white70,
              child: Icon(Icons.help_outline, color: Color(0xFF0D47A1)),
              onPressed: _openPrivacyPolicyPage,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _signInWithGoogle() async {
    try {
      LoadingDialog.show(context, message: 'Lütfen bekleyin...');

      final GoogleSignIn googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? googleSignInAccount = await googleSignIn.signIn();
      if (googleSignInAccount != null) {
        final GoogleSignInAuthentication googleSignInAuthentication = await googleSignInAccount.authentication;
        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleSignInAuthentication.accessToken,
          idToken: googleSignInAuthentication.idToken,
        );

        final UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
        final User? user = userCredential.user;

        if (user != null) {
          DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('Users').doc(user.uid).get();

          if (!userDoc.exists) {
            // New user, set first to true
            await FirebaseFirestore.instance.collection('Users').doc(user.uid).set({
              'email': user.email,
              'username': user.displayName,
              'userUID': user.uid,
              'isSubscribed': false,
              'lastButtonClickTimeForFeedback': 0,
              'first': false, // This is a new user
            });
            // Since this is a new user, navigate to profile setup
            LoadingDialog.hide(context);
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => ProfileSetupScreen()),
            );
          } else {
            // Existing user, check the 'first' field value
            bool isFirst = userDoc['first'] ?? false; // If field doesn't exist, assume true
            LoadingDialog.hide(context);

            if (isFirst) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => ProfileSetupScreen()),
              );
            } else {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => TabBarScreen()),
              );
            }
          }
        }
      } else {
        LoadingDialog.hide(context);
      }
    } catch (e) {
      LoadingDialog.hide(context);
      print('Google ile giriş sırasında hata: $e');
    }
  }

  Future<void> _signInWithApple() async {
    try {
      LoadingDialog.show(context, message: 'Lütfen bekleyin...');

      final AuthorizationCredentialAppleID appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final OAuthProvider oAuthProvider = OAuthProvider("apple.com");
      final AuthCredential credential = oAuthProvider.credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      final UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user != null) {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('Users').doc(user.uid).get();

        if (!userDoc.exists) {
          // New user, set first to true
          await FirebaseFirestore.instance.collection('Users').doc(user.uid).set({
            'email': user.email,
            'username': '${appleCredential.givenName} ${appleCredential.familyName}'.trim(),
            'userUID': user.uid,
            'isSubscribed': false,
            'lastButtonClickTimeForFeedback': 0,
            'first': true, // This is a new user
          });
          LoadingDialog.hide(context);
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => ProfileSetupScreen()),
          );
        } else {
          // Existing user, check the 'first' field value
          bool isFirst = userDoc['first'] ?? true; // If field doesn't exist, assume true
          LoadingDialog.hide(context);

          if (isFirst) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => ProfileSetupScreen()),
            );
          } else {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => TabBarScreen()),
            );
          }
        }
      }
    } catch (e) {
      LoadingDialog.hide(context);
      print('Apple ile giriş sırasında hata: $e');
    }
  }

  Future<void> _openSupportPage() async {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => ProfileSetupScreen()),
    );
  }

  Future<void> _openPrivacyPolicyPage() async {
    if (!await launchUrl(_urldestek)) {
      throw Exception('$_urldestek açılamadı');
    }
  }
}
