import 'package:flutter/material.dart';
import 'package:diyabet/screens/note/note_model.dart';
import 'package:diyabet/screens/note/detail_note_screen.dart';

class NoteCell extends StatelessWidget {
  final NoteModel note;

  const NoteCell({Key? key, required this.note}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color.fromRGBO(25, 80, 140, 1.0), // Arka plan rengi
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetailNoteScreen(note: note),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              // Özelleştirilmiş Görsel
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  image: DecorationImage(
                    image: AssetImage('assets/${note.iconName}.png'),
                    fit: BoxFit.cover,
                    colorFilter: const ColorFilter.mode(
                      Colors.white,
                      BlendMode.srcATop, // Görseli beyaza dönüştürme
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Başlık ve Tarih
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      note.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'UbuntuSans',
                        color: Colors.white, // Beyaz yazı rengi
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      note.date,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white70, // Beyaz tonlu tarih yazısı
                        fontFamily: 'UbuntuSans',
                      ),
                    ),
                  ],
                ),
              ),
              // İleri simgesi
              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.white70),
            ],
          ),
        ),
      ),
    );
  }
}
