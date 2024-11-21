// lib/widgets/note_cell.dart
import 'package:flutter/material.dart';
import 'package:diyabet/screens/note/note_model.dart';
import 'package:diyabet/screens/note/detail_note_screen.dart';

class NoteCell extends StatelessWidget {
  final NoteModel note;

  const NoteCell({Key? key, required this.note}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
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
                  shape: BoxShape.rectangle,
                  image: DecorationImage(
                    image: AssetImage('assets/${note.iconName}.png'),
                    fit: BoxFit.fill,
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
                        fontFamily: 'UbuntuSans', // Yazı tipi ayarlandı
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      note.date,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontFamily: 'UbuntuSans', // Yazı tipi ayarlandı
                      ),
                    ),
                  ],
                ),
              ),
              // İleri simgesi
              const Icon(Icons.arrow_forward_ios, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}
