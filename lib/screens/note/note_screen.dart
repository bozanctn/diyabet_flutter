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
  final User? user = FirebaseAuth.instance.currentUser;
  List<NoteModel> notes = [];
  bool isLoading = false;
  DocumentSnapshot? lastDocument;
  bool hasMore = true;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    fetchNotes();

    // ScrollController ile alt limite ulaşıldığında daha fazla veri çek
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent &&
          !isLoading &&
          hasMore) {
        fetchNotes();
      }
    });
  }

  Future<void> fetchNotes() async {
    if (user == null || isLoading || !hasMore) return;

    setState(() {
      isLoading = true;
    });

    try {
      Query query = FirebaseFirestore.instance
          .collection('Users')
          .doc(user!.uid)
          .collection('Notes')
          .orderBy('date', descending: true)
          .limit(15);

      if (lastDocument != null) {
        query = query.startAfterDocument(lastDocument!);
      }

      final snapshot = await query.get();

      if (snapshot.docs.isNotEmpty) {
        lastDocument = snapshot.docs.last;
        setState(() {
          notes.addAll(snapshot.docs.map((doc) {
            return NoteModel.fromMap(doc.data() as Map<String, dynamic>);
          }).toList());
        });
      } else {
        setState(() {
          hasMore = false; // Daha fazla veri yok
        });
      }
    } catch (e) {
      print('Error fetching notes: $e');
    } finally {
      setState(() {
        isLoading = false; // Yükleme durumu tamamlandı
      });
    }
  }

  Future<void> refreshNotes() async {
    setState(() {
      notes.clear();
      lastDocument = null;
      hasMore = true;
    });
    await fetchNotes();
  }

  void _confirmDelete(BuildContext context, String documentID) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color.fromRGBO(19, 69, 122, 1.0), // Arka plan rengi
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16), // Köşeleri yuvarlama
          ),
          title: const Text(
            'Notu Sil',
            style: TextStyle(
              color: Colors.white, // Beyaz yazı
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          content: const Text(
            'Bu notu silmek istediğinizden emin misiniz?',
            style: TextStyle(
              color: Colors.white70, // Beyaz tonlarında yazı
              fontSize: 16,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(), // Dialogu kapat
              child: const Text(
                'Hayır',
                style: TextStyle(color: Colors.white), // Beyaz yazı
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Dialogu kapat
                _deleteNote(documentID); // Notu sil
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red, // Silme butonunun arka plan rengi
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Sil',
                style: TextStyle(
                  color: Colors.white, // Beyaz yazı
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
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

      setState(() {
        notes.removeWhere((note) => note.documentID == documentID);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Not silinirken hata oluştu: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(19, 69, 122, 1.0),
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(19, 69, 122, 1.0),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: refreshNotes,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddNoteScreen()),
              ).then((value) => refreshNotes());
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: notes.isEmpty && !isLoading
                ? const Center(
              child: Text(
                'Henüz not yok.',
                style: TextStyle(color: Colors.white),
              ),
            )
                : ListView.builder(
              controller: _scrollController,
              itemCount: notes.length + (isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == notes.length) {
                  // Daha fazla veri yoksa yükleme göstergesi gösterme
                  return hasMore
                      ? const Center(child: CircularProgressIndicator())
                      : const SizedBox.shrink();
                }

                return Dismissible(
                  key: Key(notes[index].documentID),
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  direction: DismissDirection.endToStart,
                  confirmDismiss: (direction) async {
                    _confirmDelete(context, notes[index].documentID);
                    return false; // Hemen silinmesini önler
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

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
