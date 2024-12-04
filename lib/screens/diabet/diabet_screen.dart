import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:diyabet/models/med_model.dart';
import 'package:diyabet/screens/diabet/diabet_card_widget.dart';
import 'package:diyabet/screens/diabet/diabet_result_screen.dart';

class DiabetesScreen extends StatefulWidget {
  @override
  _DiabetesScreenState createState() => _DiabetesScreenState();
}

class _DiabetesScreenState extends State<DiabetesScreen> {
  List<MedModel> _medications = [];

  @override
  void initState() {
    super.initState();
    _fetchMedications();
  }

  // Fetch medications from Firestore
  void _fetchMedications() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      List<MedModel> meds = await MedModel.getMedications(user.uid);
      setState(() {
        _medications = meds;
      });
    }
  }

  // Show confirmation dialog
  void _confirmDelete(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color.fromRGBO(19, 69, 122, 1.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'İlacı Sil',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          content: const Text(
            'Bu İlacı silmek istediğinizden emin misiniz?',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(), // Dialogu kapat
              child: const Text(
                'Hayır',
                style: TextStyle(color: Colors.white),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Dialogu kapat
                _deleteMedication(index); // Silme işlemini gerçekleştir
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

  // Delete a medication
  void _deleteMedication(int index) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null && _medications[index].documentId != null) {
      try {
        await MedModel.deleteProfile(user.uid, _medications[index].documentId!);
        setState(() {
          _medications.removeAt(index); // Remove from local list
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(19, 69, 122, 1.0),
      body: _medications.isEmpty
          ? const Center(
        child: Text(
          '+ Buttonu ile ilaç ekleyin.',
          style: TextStyle(color: Colors.white),
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: _medications.length,
        itemBuilder: (context, index) {
          final med = _medications[index];
          return Dismissible(
            key: ValueKey(med.documentId),
            direction: DismissDirection.endToStart,
            confirmDismiss: (direction) async {
              // Doğrulama penceresi göster
              _confirmDelete(context, index);
              return false; // Kullanıcının doğrulaması beklenir
            },
            background: Container(
              color: Colors.red,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            child: MedicationCard(
              medication: med,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        DiabetResultPage(medication: med),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
