import 'package:diyabet/screens/profile/profile_update_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:diyabet/screens/calculator/view/input_page.dart'; // Boy Kilo Index Hesaplama Ekranı
import '../../models/user_model.dart';

class ProfilePage extends StatelessWidget {
  Future<UserProfile?> _fetchProfile() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return await UserProfile.getProfile(user.uid);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(19, 69, 122, 1.0),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: FutureBuilder<UserProfile?>(
                future: _fetchProfile(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  }
                  if (snapshot.hasError) {
                    return const Text(
                      "Profil verileri yüklenirken bir hata oluştu.",
                      style: TextStyle(color: Colors.white),
                    );
                  }
                  if (!snapshot.hasData) {
                    return const Text(
                      "Profil verileri yüklenemedi.",
                      style: TextStyle(color: Colors.white),
                    );
                  }

                  UserProfile? profile = snapshot.data;
                  return Column(
                    children: [
                      // Kullanıcı görseli ve bilgilerinin bulunduğu kart
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF1D4C73), // Kart rengi
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            // Profil görseli
                            CircleAvatar(
                              radius: 50,
                              backgroundImage: profile!.profileImageUrl.isNotEmpty
                                  ? NetworkImage(profile.profileImageUrl)
                                  : const AssetImage('assets/images/default_avatar.png')
                              as ImageProvider,
                              backgroundColor: Colors.transparent,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              '${profile.name} ${profile.surname}',
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white, // Beyaz isim yazısı
                              ),
                            ),
                            const SizedBox(height: 8),
                            Divider(color: Colors.grey.shade300, thickness: 1),
                            ListTile(
                              leading: const Icon(Icons.person, color: Colors.white),
                              title: Text(
                                'Cinsiyet: ${profile.gender}',
                                style: const TextStyle(color: Colors.white, fontSize: 16),
                              ),
                            ),
                            ListTile(
                              leading: const Icon(Icons.cake, color: Colors.white),
                              title: Text(
                                'Doğum Tarihi: ${profile.birthdate.year}/${profile.birthdate.month}/${profile.birthdate.day}',
                                style: const TextStyle(color: Colors.white, fontSize: 16),
                              ),
                            ),
                            ListTile(
                              leading: const Icon(Icons.monitor_weight, color: Colors.white),
                              title: Text(
                                'Kilo: ${profile.weight} kg',
                                style: const TextStyle(color: Colors.white, fontSize: 16),
                              ),
                            ),
                            ListTile(
                              leading: const Icon(Icons.height, color: Colors.white),
                              title: Text(
                                'Boy: ${profile.height} cm',
                                style: const TextStyle(color: Colors.white, fontSize: 16),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Modernize edilmiş "Bilgilerimi Düzenle" butonu
                      ElevatedButton.icon(
                        icon: const Icon(Icons.edit, color: Colors.white),
                        label: const Text(
                          "Bilgilerimi Düzenle",
                          style: TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1C5DA1), // Modern mavi buton rengi
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                          elevation: 5,
                          shadowColor: Colors.black.withOpacity(0.2),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => CreateProfileScreen()),
                          );
                        },
                      ),
                      const SizedBox(height: 20),
                      // Modernize edilmiş "Vücut Kilo İndeksi Hesapla" butonu
                      ElevatedButton.icon(
                        icon: const Icon(Icons.calculate, color: Colors.white),
                        label: const Text(
                          "Vücut Kilo İndeksini Hesapla",
                          style: TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF24D876), // Modern yeşil buton rengi
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                          elevation: 5,
                          shadowColor: Colors.black.withOpacity(0.2),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => InputPage()),
                          );
                        },
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
