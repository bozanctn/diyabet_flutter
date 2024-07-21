import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddFeedbackScreen extends StatefulWidget {
  @override
  _AddFeedbackScreenState createState() => _AddFeedbackScreenState();
}

class _AddFeedbackScreenState extends State<AddFeedbackScreen> {
  final TextEditingController _postTextController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _postTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Görüş Bildir"),
        actions: [
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: _didTapSendButton,
          ),
        ],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _didTapBackButton,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: TextField(
                controller: _postTextController,
                maxLines: null,
                decoration: InputDecoration(
                  hintText: "Bir Metin Girin..",
                  fillColor: Theme.of(context).cardColor,
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _didTapSendButton() async {
    // Firebase işlemleri burada olacak
    String postText = _postTextController.text;
    if (postText.isEmpty) {
      // Kullanıcıya hata mesajı göster
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Lütfen bir metin girin.")),
      );
      return;
    }

    try {
      User? user = _auth.currentUser;
      if (user != null) {
        String userUID = user.uid;
        await _firestore.collection('Feedback').add({
          'title': postText,
          'userUID': userUID,
          'date': FieldValue.serverTimestamp(),
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Görüşünüz gönderildi.")),
        );
        _postTextController.clear();
        Navigator.of(context).pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Kullanıcı oturumu açılamadı.")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Bir hata oluştu: $e")),
      );
    }
  }

  void _didTapBackButton() {
    Navigator.of(context).pop();
  }
}
