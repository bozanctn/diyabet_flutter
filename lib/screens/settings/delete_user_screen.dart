import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../login/login_screen.dart';

class DeleteCurrentUserScreen extends StatefulWidget {
  @override
  _DeleteCurrentUserScreenState createState() => _DeleteCurrentUserScreenState();
}

class _DeleteCurrentUserScreenState extends State<DeleteCurrentUserScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController _reasonController = TextEditingController();

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
      backgroundColor: const Color.fromRGBO(19, 69, 122, 1.0),
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(19, 69, 122, 1.0),
        centerTitle: true,
        title: const Text(
          'Hesabı Sil',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 24),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Neden seçimi için radyo butonları
              ..._reasons.map((reason) => RadioListTile(
                activeColor: Colors.white,
                selectedTileColor: Colors.white70,
                title: Text(
                  reason,
                  style: TextStyle(
                    color: _selectedReason == reason ? Colors.white : Colors.white70,
                  ),
                ),
                value: reason,
                groupValue: _selectedReason,
                onChanged: (value) {
                  setState(() {
                    _selectedReason = value ?? '';
                  });
                },
              )),
              const SizedBox(height: 16),
              // Ekstra neden textfield
              TextField(
                controller: _reasonController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Ekstra Neden (isteğe bağlı)',
                  labelStyle: const TextStyle(color: Colors.white),
                  hintText: 'Detaylı neden belirtmek isterseniz...',
                  hintStyle: const TextStyle(color: Colors.white70),
                  filled: true,
                  fillColor: const Color.fromRGBO(255, 255, 255, 0.1),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.white24),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.white),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 20),
              // Hesap Silme Butonu
              ElevatedButton(
                onPressed: _deleteAccount,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Hesabımı Kalıcı Olarak Kapat',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "*Başka bir neden varsa lütfen belirtin.\nHesabınız ve bütün verileriniz geri döndürülemez şekilde silinecektir.",
                style: TextStyle(color: Colors.red, fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
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

      String reason = _selectedReason.isNotEmpty ? _selectedReason : "Belirtilmemiş";
      String additionalReason = _reasonController.text.trim();

      // Kullanıcı doğrulama işlemi (Google/Apple)
      await _reauthenticateUser(user);

      await _firestore.collection('DeletedUsers').doc(user.uid).set({
        'email': user.email ?? 'Gizli',
        'selectedFilter': reason,
        'additionalReason': additionalReason,
        'deletedAt': DateTime.now(),
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

  // Kullanıcıyı Google ile yeniden doğrulama
  Future<void> _reauthenticateUser(User user) async {
    if (user.providerData.any((provider) => provider.providerId == 'google.com')) {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        throw Exception("Google doğrulama başarısız.");
      }
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
        accessToken: googleAuth.accessToken,
      );
      await user.reauthenticateWithCredential(credential);
    }
    // Buraya Apple doğrulaması ekleyebilirsiniz.
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: Colors.red,
    ));
  }
}
