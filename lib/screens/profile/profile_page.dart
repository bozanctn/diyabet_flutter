import 'package:diyabet/screens/profile/profile_update_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../models/user_model.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Future<UserProfile?> _fetchProfile() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return await UserProfile.getProfile(user.uid);
    }
    return null;
  }

  late Future<UserProfile?> _profileFuture;

  @override
  void initState() {
    super.initState();
    _profileFuture = _fetchProfile(); // İlk yükleme sırasında veriyi çekiyoruz
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(19, 69, 122, 1.0),
      body: SafeArea(
        child: Center(
          child: FutureBuilder<UserProfile?>(
            future: _profileFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              }
              if (!snapshot.hasData) {
                return Text("Profil verileri yüklenemedi");
              }
              UserProfile? profile = snapshot.data;
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey.shade200,
                    child: Icon(
                      Icons.person,
                      color: Colors.grey.shade800,
                      size: 50,
                    ),
                  ),
                  SizedBox(height: 24),
                  if (profile != null) ...[
                    Text(
                      '${profile.name} ${profile.surname}',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Cinsiyet: ${profile.gender}',
                      style: TextStyle(fontSize: 18, color: Colors.white70),
                    ),
                    Text(
                      'Doğum Tarihi: ${profile.birthdate.year}/${profile.birthdate.month}/${profile.birthdate.day}',
                      style: TextStyle(fontSize: 18, color: Colors.white70),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Kilo: ${profile.weight} kg',
                      style: TextStyle(fontSize: 18, color: Colors.white70),
                    ),
                    Text(
                      'Boy: ${profile.height} cm',
                      style: TextStyle(fontSize: 18, color: Colors.white70),
                    ),
                    SizedBox(height: 24),
                  ],
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.black, backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    ),
                    onPressed: () async {
                      // ProfileUpdatePage'den dönen sonucu bekliyoruz
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ProfileUpdatePage()),
                      );
                      if (result == true) {
                        // Eğer veri güncellenmişse, sayfayı tekrar yüklüyoruz
                        setState(() {
                          _profileFuture = _fetchProfile();
                        });
                      }
                    },
                    child: Text("Bilgilerimi Düzenle"),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
