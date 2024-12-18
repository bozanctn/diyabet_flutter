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
      backgroundColor: const Color.fromRGBO(19, 69, 122, 1.0),
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: const Color.fromRGBO(19, 69, 122, 1.0),
        elevation: 0,
        title: const Text(
          'Not Detayı',
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white),
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
                  ColorFiltered(
                    colorFilter: const ColorFilter.mode(
                      Colors.white, // Hedef renk
                      BlendMode.srcIn, // Renkleri karıştırma modu
                    ),
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Image.asset('assets/${note.iconName}.png'),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
            // Başlık
            Center(
              child: Text(
                note.title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'UbuntuSans',
                  color: Colors.white,
                ),
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
                  icon: const Icon(
                    Icons.copy,
                    color: Colors.white,
                  ),
                  label: const Text(
                    'Kopyala',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'UbuntuSans',
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange.withOpacity(0.7),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                Text(
                  note.date,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
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
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Metni panoya kopyalama fonksiyonu
  void _copyToClipboard(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Not başarıyla kopyalandı!'),
      ),
    );
  }
}
