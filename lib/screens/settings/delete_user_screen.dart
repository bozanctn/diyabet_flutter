import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../login/login_screen.dart';

class DeleteCurrentUserScreen extends StatefulWidget {
  @override
  _DeleteCurrentUserScreenState createState() => _DeleteCurrentUserScreenState();
}

class _DeleteCurrentUserScreenState extends State<DeleteCurrentUserScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController _reasonController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String _selectedReason = '';
  List<String> _reasons = [
    "Bilgilerim Güvende Değil",
    "Uygulamadan Memnun Değilim",
    "Uygunsuz İçerikler Mevcut",
    "Hesabımda Sorun Var",
    "Belirtmek İstemiyorum"
  ];

  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hesabı Sil'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              ..._reasons.map((reason) => RadioListTile(
                title: Text(reason),
                value: reason,
                groupValue: _selectedReason,
                onChanged: (value) {
                  setState(() {
                    _selectedReason = value ?? '';
                  });
                },
              )),
              TextField(
                controller: _reasonController,
                decoration: const InputDecoration(
                  labelText: 'Ekstra Neden (isteğe bağlı)',
                ),
              ),
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Şifre',
                ),
                obscureText: true,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _deleteAccount,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Hesabımı Kalıcı Olarak Kapat',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
              TextButton(
                onPressed: _clearFields,
                child: const Text('Temizle',
                  style: TextStyle(color: Colors.black
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "*Başka bir neden varsa lütfen belirtin.\nHesabınız ve bütün verileriniz geri döndürülemez şekilde silinecektir.",
                style: TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _clearFields() {
    _reasonController.clear();
    _passwordController.clear();
    setState(() {
      _selectedReason = '';
    });
  }

  Future<void> _deleteAccount() async {
    setState(() {
      _isLoading = true;
    });

    try {
      User? user = _auth.currentUser;
      if (user == null) {
        _showError('Hata: Mevcut kullanıcı yok.');
        return;
      }

      String email = user.email ?? '';
      String password = _passwordController.text.trim();

      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      String reason = _selectedReason;
      String additionalReason = _reasonController.text.trim();

      await _firestore.collection('DeletedUsers').doc(user.uid).set({
        'email': email,
        'selectedFilter': reason,
        'additionalReason': additionalReason,
      });

      await _firestore.collection('Users').doc(user.uid).delete();

      await user.delete();

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    } catch (e) {
      _showError('Hata oluştu: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: Colors.red,
    ));
  }
}
