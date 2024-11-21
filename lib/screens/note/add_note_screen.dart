// lib/screens/add_note_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart'; // Tarih formatlamak için intl paketi eklendi
import 'package:diyabet/screens/note/note_model.dart';


class AddNoteScreen extends StatefulWidget {
  @override
  _AddNoteScreenState createState() => _AddNoteScreenState();
}

class _AddNoteScreenState extends State<AddNoteScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  int _selectedSegmentIndex = 0;

  // Segment Kontrol seçenekleri
  final List<String> _segments = ["📕 Ders", "📅 Etkinlik", "📓 Kişisel"];
  final List<String> _segmentsResult = ["Ders", "Etkinlik", "Kişisel"];

  @override
  Widget build(BuildContext context) {
    // Klavye yüksekliğini kontrol etmek için MediaQuery kullanımı
    final keyboardHeight = MediaQuery
        .of(context)
        .viewInsets
        .bottom;

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
            // Segment Kontrol
            Center(
              child: ToggleButtons(
                borderRadius: BorderRadius.circular(8),
                // Buton köşe yuvarlama
                fillColor: Colors.blueGrey,
                // Seçili buton arka plan rengi
                selectedColor: Colors.white,
                // Seçili buton yazı rengi
                selectedBorderColor: Colors.blue,
                // Seçili buton kenarlık rengi
                color: Colors.black87,
                // Seçili olmayan buton yazı rengi
                textStyle: const TextStyle(
                  fontFamily: 'UbuntuSans',
                  fontWeight: FontWeight.bold,
                ),
                constraints: const BoxConstraints(
                  minHeight: 40, // Minimum buton yüksekliği
                  minWidth: 80, // Minimum buton genişliği
                ),
                isSelected: List.generate(
                    _segments.length, (index) =>
                _selectedSegmentIndex == index),
                children: _segments.map((e) =>
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      child: Text(
                        e,
                        style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.normal,
                            fontFamily: 'UbuntuSans'
                        ),
                      ),
                    )).toList(),
                onPressed: (index) {
                  setState(() {
                    _selectedSegmentIndex = index;
                  });
                },
              ),
            ),
            const SizedBox(height: 20),
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
            // Açıklama Giriş Alanı
            Container(
              constraints: const BoxConstraints(
                maxHeight: 300, // Not alanının maksimum yüksekliği
              ),
              child: TextField(
                controller: _noteController,
                maxLength: 5000,
                // Not için 5000 karakter sınırı
                maxLines: 30,
                // Maksimum satır sayısı sınırlı
                decoration: const InputDecoration(
                  labelStyle: TextStyle(color: focusedBorderColor),
                  labelText: 'Not:',
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: borderColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: focusedBorderColor, width: 2.0),
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
            Center(
              child: ElevatedButton(
                onPressed: _saveNote,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueGrey, // Buton rengi
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: 24.0, vertical: 12.0),
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

  void _saveNote() async {
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

    final String documentID = _firestore
        .collection('Notes')
        .doc()
        .id;

    // Tarih ve zamanı istenen formatta ayarlamak
    final String formattedDate = DateFormat('dd MMM yyyy | HH:mm').format(
        DateTime.now());

    // Seçilen segment'e göre result değerini al
    final String selectedSegmentResult = _segmentsResult[_selectedSegmentIndex];

    // "Ders" seçilmişse sadece "Ders" metnini kaydet, değilse normal segment ismini kullan
    final String iconName = selectedSegmentResult == "Ders"
        ? "Ders"
        : _segmentsResult[_selectedSegmentIndex];

    final NoteModel noteModel = NoteModel(
      title: title,
      note: note,
      date: formattedDate,
      // Tarih ve zaman formatlı kaydediliyor
      iconName: iconName,
      documentID: documentID,
      userUID: user.uid,
    );

    try {
      await _firestore
          .collection('Users')
          .doc(user.uid)
          .collection('Notes')
          .doc(documentID)
          .set(noteModel.toMap());

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Not başarıyla kaydedildi!')),
      );
      Navigator.of(context).pop(); // Not kaydedildikten sonra geri dön
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Not kaydedilirken hata oluştu: $e')),
      );
    }
  }
}