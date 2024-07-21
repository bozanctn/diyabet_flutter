import 'package:diyabet/screens/profile/profile_update_page.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Bilgilerim', style: TextStyle(color: Colors.black)),
        centerTitle: true,
        backgroundColor: Color(0xFF6EC6FF),
        elevation: 0,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF6EC6FF), Color(0xFF2D5CFF)],
          ),
        ),
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: 80), // Avatarın app bar ile çakışmaması için boşluk
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ProfileUpdatePage()),
                      );
                    },
                    child: Text("Profil Bilgilerimi Değiştir"),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 10,
              left: 150,
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Colors.black,
                child: Icon(
                  Icons.person,
                  color: Colors.white,
                  size: 50,
                ),
              ),
            ),
            Positioned(
              top: 10,
              left: 150,
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Colors.black,
                child: Icon(
                  Icons.person,
                  color: Colors.white,
                  size: 50,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
