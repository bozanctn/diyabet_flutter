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
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      backgroundColor: const Color.fromRGBO(19, 69, 122, 1.0),
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(19, 69, 122, 1.0),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Not Düzenle',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(
          left: 16.0,
          right: 16.0,
          top: 16.0,
          bottom: keyboardHeight,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            // Başlık Giriş Alanı
            TextField(
              controller: _titleController,
              maxLength: 120,
              decoration: const InputDecoration(
                labelStyle: TextStyle(color: Colors.white),
                labelText: 'Başlık...',
                border: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white, width: 2.0),
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
                counterText: '',
              ),
              style: const TextStyle(
                fontFamily: 'UbuntuSans',
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            // Not Giriş Alanı
            Container(
              constraints: const BoxConstraints(
                maxHeight: 300,
              ),
              child: TextField(
                controller: _noteController,
                maxLength: 5000,
                maxLines: 30,
                decoration: const InputDecoration(
                  labelStyle: TextStyle(color: Colors.white),
                  labelText: 'Not...',
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white, width: 2.0),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                  counterText: '',
                ),
                style: const TextStyle(
                  fontFamily: 'UbuntuSans',
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Kaydet Butonu
            Center(
              child: ElevatedButton(
                onPressed: _updateNote,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
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
      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Not güncellenirken hata oluştu: $e')),
      );
    }
  }
}
