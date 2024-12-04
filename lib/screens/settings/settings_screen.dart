import 'package:diyabet/screens/settings/add_feedback_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../login/login_screen.dart';
import '../../helper/alert_messages.dart';
import 'delete_user_screen.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool isLogoutFlushbarShowing = false;
  bool isFeedbackFlushbarShowing = false;

  void _didTapFeedback(BuildContext context) {
    if (isFeedbackFlushbarShowing) return;

    setState(() {
      isFeedbackFlushbarShowing = true;
    });

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddFeedbackScreen()),
    ).then((_) {
      setState(() {
        isFeedbackFlushbarShowing = false;
      });
    });
  }

  Future<void> _signOut(BuildContext context) async {
    final GoogleSignIn googleSignIn = GoogleSignIn();

    try {
      await FirebaseAuth.instance.signOut();
      await googleSignIn.signOut();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
            (Route<dynamic> route) => false,
      );
    } catch (e) {
      print('Error signing out: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error signing out. Please try again.')),
      );
    }
  }

  void _didTapLogout(BuildContext context) {
    if (isLogoutFlushbarShowing) return;

    setState(() {
      isLogoutFlushbarShowing = true;
    });

    AlertMessages.showAdvancedInfoBottom(
      context,
      title: 'Çıkış Yap',
      message: 'Çıkış yapmak istediğinizden emin misiniz?',
      buttonTitle: 'Çıkış',
      completion: (bool confirmed) async {
        if (confirmed) {
          await _signOut(context);
        }
        setState(() {
          isLogoutFlushbarShowing = false;
        });
      },
    );

    Future.delayed(Duration(seconds: 2), () {
      setState(() {
        isLogoutFlushbarShowing = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(19, 69, 122, 1.0),
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Ayarlar',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 24),
        ),
        backgroundColor: const Color.fromRGBO(19, 69, 122, 1.0),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: Colors.white,
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_remove),
            color: Colors.red,
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => DeleteCurrentUserScreen()),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            _buildCombinedButton(
              context,
              'Görüş Bildir',
              Icons.textsms_outlined,
                  () => _didTapFeedback(context),
            ),
            const SizedBox(height: 16),
            _buildCombinedButton(
              context,
              'Çıkış',
              Icons.logout,
                  () => _didTapLogout(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCombinedButton(BuildContext context, String title, IconData icon, VoidCallback onTap) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 24, color: Colors.white),
      label: Text(title, style: const TextStyle(fontSize: 16, color: Colors.white)),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.black.withOpacity(0.5),
        minimumSize: const Size(double.infinity, 60),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
