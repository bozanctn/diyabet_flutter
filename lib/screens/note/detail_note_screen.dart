// lib/screens/detail_note_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:diyabet/screens/note/note_model.dart';
import 'package:diyabet/screens/note/edit_note_screen.dart';

class DetailNoteScreen extends StatelessWidget {
  final NoteModel note;

  const DetailNoteScreen({Key? key, required this.note}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditNoteScreen(note: note),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Görsel ve İkon İsmi
            Center(
              child: Column(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      image: DecorationImage(
                        image: AssetImage('assets/${note.iconName}.png'),
                        fit: BoxFit.fill,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    note.iconName,
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                      fontFamily: 'UbuntuSans',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Başlık
            Text(
              textAlign: TextAlign.center,
              note.title,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                fontFamily: 'UbuntuSans',
              ),
            ),
            const SizedBox(height: 10),
            // Kopyala ve Tarih
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    _copyToClipboard(context, note.note);
                  },
                  icon: const Icon(Icons.copy, color: Colors.black38,),
                  label: const Text('Kopyala',
                    style: TextStyle(color: Colors.black38, fontFamily: 'UbuntuSans'),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueGrey.shade50,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                Text(
                  note.date,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                    fontFamily: 'UbuntuSans',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Not İçeriği
            Text(
              note.note,
              style: const TextStyle(
                fontSize: 16,
                fontFamily: 'UbuntuSans',
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Metin panoya kopyalama fonksiyonu
  void _copyToClipboard(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Not başarıyla kopyalandı!'),
      ),
    );
  }
}
