import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:diyabet/screens/blood_sugar/blood_sugar_model.dart';

class BloodSugarDataPage extends StatefulWidget {
  @override
  _BloodSugarDataPageState createState() => _BloodSugarDataPageState();
}

class _BloodSugarDataPageState extends State<BloodSugarDataPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<BloodSugarModel> entries = [];
  bool isLoading = false;
  bool hasMore = true;
  DocumentSnapshot? lastDocument;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    fetchData();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent &&
          !isLoading &&
          hasMore) {
        loadMoreData();
      }
    });
  }

  Future<void> fetchData() async {
    final user = _auth.currentUser;
    if (user == null || isLoading) return;

    setState(() {
      isLoading = true;
    });

    try {
      Query query = _firestore
          .collection('Users')
          .doc(user.uid)
          .collection('Insulin')
          .orderBy('date', descending: true)
          .limit(15);

      if (lastDocument != null) {
        query = query.startAfterDocument(lastDocument!);
      }

      final snapshot = await query.get();

      if (snapshot.docs.isNotEmpty) {
        lastDocument = snapshot.docs.last;
        setState(() {
          entries.addAll(snapshot.docs.map((doc) {
            return BloodSugarModel.fromMap(
              doc.data() as Map<String, dynamic>,
              doc.id, // Firestore'dan gelen belge ID'sini kullan
            );
          }).toList());
        });
      } else {
        setState(() {
          hasMore = false;
        });
      }
    } catch (e) {
      print("Error fetching data: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> loadMoreData() async {
    if (!hasMore || isLoading) return;

    await fetchData();
  }

  Future<void> refreshData() async {
    setState(() {
      entries.clear();
      lastDocument = null;
      hasMore = true;
    });
    await fetchData();
  }

  void _showAddEntryDialog() {
    final TextEditingController bloodSugarController = TextEditingController();
    final TextEditingController insulinUnitController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color.fromRGBO(19, 69, 122, 1.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Yeni Değer Ekle',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: bloodSugarController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Kan Şekeri (mg/dL)',
                    labelStyle: const TextStyle(color: Colors.white70),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Colors.white70),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Colors.white),
                    ),
                  ),
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: insulinUnitController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'İnsülin (Ünite)',
                    labelStyle: const TextStyle(color: Colors.white70),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Colors.white70),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Colors.white),
                    ),
                  ),
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'İptal',
                style: TextStyle(color: Colors.white),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                final String bloodSugar = bloodSugarController.text.trim();
                final String insulinUnit = insulinUnitController.text.trim();

                if (bloodSugar.isEmpty || insulinUnit.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Tüm alanları doldurun!')),
                  );
                  return;
                }

                final user = _auth.currentUser;
                if (user == null) return;

                final String formattedDate = DateFormat('dd MMM yyyy | HH:mm').format(DateTime.now());

                try {
                  // Veriyi Firestore'a kaydet
                  final DocumentReference docRef = await _firestore
                      .collection('Users')
                      .doc(user.uid)
                      .collection('Insulin')
                      .add({
                    'userUID': user.uid,
                    'date': formattedDate,
                    'bloodSugar': bloodSugar,
                    'insulinUnit': insulinUnit,
                  });

                  // Modeli listenin başına ekle
                  setState(() {
                    entries.insert(
                      0, // Listenin başına eklemek için indeks 0
                      BloodSugarModel(
                        documentID: docRef.id,
                        userUID: user.uid,
                        date: formattedDate,
                        bloodSugar: bloodSugar,
                        insulinUnit: insulinUnit,
                      ),
                    );
                  });

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Veri başarıyla kaydedildi!')),
                  );
                  Navigator.pop(context);
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Kayıt sırasında hata oluştu: $e')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Ekle',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }



  void _confirmDelete(BuildContext context, BloodSugarModel entry) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color.fromRGBO(19, 69, 122, 1.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Veriyi Sil',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          content: const Text(
            'Bu veriyi silmek istediğinizden emin misiniz?',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Hayır',
                style: TextStyle(color: Colors.white),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop(); // Diyaloğu kapat
                await _deleteEntry(entry); // Veriyi sil
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Sil',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteEntry(BloodSugarModel entry) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      await _firestore
          .collection('Users')
          .doc(user.uid)
          .collection('Insulin')
          .doc(entry.documentID) // Firestore'dan gelen documentID kullanılıyor
          .delete();

      setState(() {
        entries.remove(entry); // Listeyi güncelle
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veri başarıyla silindi!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Veri silinirken hata oluştu: $e')),
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
        leading:  IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: refreshData,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddEntryDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: entries.isEmpty && !isLoading
                ? const Center(
              child: Text(
                'Henüz veri yok.',
                style: TextStyle(color: Colors.white),
              ),
            )
                : ListView.builder(
              controller: _scrollController,
              itemCount: entries.length + (isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == entries.length) {
                  return hasMore
                      ? const Center(child: CircularProgressIndicator())
                      : const SizedBox.shrink();
                }

                final entry = entries[index];

                return Dismissible(
                  key: Key(entry.documentID), // Benzersiz documentID kullanılıyor
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  direction: DismissDirection.endToStart,
                  confirmDismiss: (direction) async {
                    _confirmDelete(context, entry);
                    return false; // Hemen silmeyi engelle
                  },
                  child: Card(
                    color: const Color.fromRGBO(245, 245, 245, 1),
                    margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 2,
                    child: ListTile(
                      title: Text(
                        'Kan Şekeri: ${entry.bloodSugar} mg/dL',
                        style: const TextStyle(color: Colors.black87),
                      ),
                      subtitle: Text(
                        'İnsülin: ${entry.insulinUnit} ünite\nTarih: ${entry.date}',
                        style: const TextStyle(color: Colors.black54),
                      ),
                    ),
                  ),
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
