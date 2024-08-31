import 'package:diyabet/screens/login/profile_info.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sign_in_button/sign_in_button.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:diyabet/helper/loading_screen.dart';
import '../tabbar.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final Uri _url = Uri.parse('http://www.linkmis.info.tr');
  final Uri _urldestek = Uri.parse('https://www.linkmis.info.tr/privacy-policy/');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/bg7.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(
            color: Colors.white,
          ),
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.6),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Uygulamaya Hoş Geldiniz\nLütfen Giriş Yapınız!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
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
                Center(
                  child: TextButton(
                    onPressed: _openSupportPage,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      backgroundColor: Colors.black.withOpacity(0.5),
                    ),
                    child: const Text(
                      'Destek Alın',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 16,
            right: 16,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(25),
              ),
              child: IconButton(
                icon: Icon(
                  Icons.help_outline,
                  color: Colors.white,
                  size: 30,
                ),
                onPressed: _openPrivacyPolicyPage,
              ),
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
            await FirebaseFirestore.instance.collection('Users').doc(user.uid).set({
              'email': user.email,
              'username': user.displayName,
              'userUID': user.uid,
              'isSubscribed': false,
              'lastButtonClickTimeForFeedback': 0,
              'first': true,
            });
          }

          bool isFirst = userDoc.exists ? userDoc['first'] ?? true : true;
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
      } else {
        LoadingDialog.hide(context);
        // Handle case when user cancels Google sign-in
      }
    } catch (e) {
      LoadingDialog.hide(context);
      print('Google ile giriş sırasında hata: $e');
      // Display an error message to the user if needed
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
