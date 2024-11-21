// lib/screens/edit_note_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:diyabet/screens/note/note_model.dart';

class EditNoteScreen extends StatefulWidget {
  final NoteModel note;

  const EditNoteScreen({Key? key, required this.note}) : super(key: key);

  @override
  _EditNoteScreenState createState() => _EditNoteScreenState();
}

class _EditNoteScreenState extends State<EditNoteScreen> {
  late TextEditingController _titleController;
  late TextEditingController _noteController;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note.title);
    _noteController = TextEditingController(text: widget.note.note);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Klavye yüksekliğini kontrol etmek için MediaQuery kullanımı
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    // Özelleştirilmiş border renkleri
    const borderColor = Colors.blueGrey;
    const focusedBorderColor = Colors.blue;
    const errorBorderColor = Colors.red;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: EdgeInsets.only(
          left: 16.0,
          right: 16.0,
          top: 16.0,
          bottom: keyboardHeight, // Klavye açıldığında padding ekleniyor
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Başlık Giriş Alanı
            TextField(
              controller: _titleController,
              maxLength: 120, // Başlık için 120 karakter sınırı
              decoration: const InputDecoration(
                labelStyle: TextStyle(color: focusedBorderColor),
                labelText: 'Başlık...',
                border: UnderlineInputBorder(
                  borderSide: BorderSide(color: borderColor),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: focusedBorderColor, width: 2.0),
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: borderColor),
                ),
                errorBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: errorBorderColor),
                ),
                counterText: '', // Karakter sayacı gizleme
              ),
              style: const TextStyle(
                fontFamily: 'UbuntuSans',
              ),
            ),
            const SizedBox(height: 20),
            // Not Giriş Alanı
            Container(
              constraints: const BoxConstraints(
                maxHeight: 300, // Not alanının maksimum yüksekliği
              ),
              child: TextField(
                controller: _noteController,
                maxLength: 5000, // Not için 5000 karakter sınırı
                maxLines: 30, // Maksimum satır sayısı sınırlı
                decoration: const InputDecoration(
                  labelStyle: TextStyle(color: focusedBorderColor),
                  labelText: 'Not:',
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: borderColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: focusedBorderColor, width: 2.0),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: borderColor),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: errorBorderColor),
                  ),
                  counterText: '', // Karakter sayacı gizleme
                ),
                style: const TextStyle(
                  fontFamily: 'UbuntuSans',
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Kaydet Butonu
            Center( // Butonu ortalamak için Center widget'ı kullanıldı
              child: ElevatedButton(
                onPressed: _updateNote,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueGrey, // Buton rengi
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0), // Butonun boyutunu arttırmak için padding eklendi
                  child: Text(
                    'Kaydet',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'UbuntuSans',
                      fontWeight: FontWeight.normal,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _updateNote() async {
    final String title = _titleController.text.trim();
    final String note = _noteController.text.trim();

    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Başlık alanı boş olamaz.')),
      );
      return;
    }

    final User? user = _auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen giriş yapın.')),
      );
      return;
    }

    final String documentID = widget.note.documentID;

    final updatedNote = NoteModel(
      title: title,
      note: note,
      date: DateTime.now().toLocal().toString().split(' ')[0],
      iconName: widget.note.iconName,
      documentID: documentID,
      userUID: user.uid,
    );

    try {
      await _firestore
          .collection('Users')
          .doc(user.uid)
          .collection('Notes')
          .doc(documentID)
          .update(updatedNote.toMap());

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Not başarıyla güncellendi!')),
      );
      Navigator.of(context).pop(); // Güncellendikten sonra geri dön
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Not güncellenirken hata oluştu: $e')),
      );
    }
  }
}
