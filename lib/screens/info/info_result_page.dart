import 'package:flutter/material.dart';

class InfoResultPage extends StatelessWidget {
  final String title;
  final String description;

  const InfoResultPage({super.key, required this.title, required this.description});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(19, 69, 122, 1.0), // Arka plan rengi
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(19, 69, 122, 1.0),
        centerTitle: true,
        title: const Text("S.S.S",
          style: TextStyle(color: Colors.white),
        ),
        // Başlığı göster
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              description,
              style: const TextStyle(
                fontSize: 18,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
