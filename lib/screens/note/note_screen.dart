// lib/screens/note_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diyabet/screens/note/note_model.dart';
import 'package:diyabet/screens/note/note_cell.dart';
import 'package:diyabet/screens/note/add_note_screen.dart';

class NoteScreen extends StatefulWidget {
  @override
  _NoteScreenState createState() => _NoteScreenState();
}

class _NoteScreenState extends State<NoteScreen> {
  List<NoteModel> notes = [];
  final User? user = FirebaseAuth.instance.currentUser;
  int _selectedSegmentIndex = 0;
  final List<String> _segments = ["🗒️ Tümü", "📕 Ders", "📅 Etkinlik", "📓 Kişisel"];

  @override
  void initState() {
    super.initState();
    fetchNotes();
  }

  void fetchNotes() {
    if (user == null) return;

    Query query = FirebaseFirestore.instance
        .collection('Users')
        .doc(user!.uid)
        .collection('Notes')
        .orderBy('date', descending: true);

    // Segment kontrolüne göre filtre uygula
    switch (_selectedSegmentIndex) {
      case 1:
        query = query.where('iconName', isEqualTo: 'Ders');
        break;
      case 2:
        query = query.where('iconName', isEqualTo: 'Etkinlik');
        break;
      case 3:
        query = query.where('iconName', isEqualTo: 'Kişisel');
        break;
      default:
        break;
    }

    query.snapshots().listen((snapshot) {
      setState(() {
        notes = snapshot.docs.map((doc) {
          return NoteModel.fromMap(doc.data() as Map<String, dynamic>);
        }).toList();
      });
    });
  }

  void _deleteNote(String documentID) async {
    try {
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(user!.uid)
          .collection('Notes')
          .doc(documentID)
          .delete();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Not başarıyla silindi!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Not silinirken hata oluştu: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddNoteScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // ToggleButtons özelleştirme
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ToggleButtons(
              borderRadius: BorderRadius.circular(8),
              fillColor: Colors.blueGrey,
              selectedColor: Colors.white,
              selectedBorderColor: Colors.blue,
              color: Colors.black87,
              textStyle: const TextStyle(
                fontFamily: 'UbuntuSans',
                fontWeight: FontWeight.bold,
              ),
              constraints: const BoxConstraints(
                minHeight: 40,
                minWidth: 80,
              ),
              isSelected: List.generate(
                  _segments.length, (index) => _selectedSegmentIndex == index),
              children: _segments.map((e) => Padding(
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
                  fetchNotes();
                });
              },
            ),
          ),
          Expanded(
            child: notes.isEmpty
                ? const Center(child: Text('Henüz not yok.'))
                : ListView.builder(
              itemCount: notes.length,
              itemBuilder: (context, index) {
                return Dismissible(
                  key: Key(notes[index].documentID), // Her öğe için benzersiz bir anahtar
                  background: Container(
                    color: Colors.red, // Kaydırma arka plan rengi
                    alignment: Alignment.centerLeft, // Metin hizalaması
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: const Icon(Icons.delete, color: Colors.white), // Silme ikonu
                  ),
                  direction: DismissDirection.endToStart, // Sadece sağdan sola kaydırma
                  onDismissed: (direction) {
                    _deleteNote(notes[index].documentID); // Belgeyi Firestore'dan sil
                    setState(() {
                      notes.removeAt(index); // UI'dan öğeyi kaldır
                    });
                  },
                  child: NoteCell(note: notes[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
