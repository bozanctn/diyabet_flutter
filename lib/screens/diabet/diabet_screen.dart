import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:diyabet/models/med_model.dart';
import '../med/medicine_page.dart';

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

  // Navigate to MedicinePage and add new medication
  Future<void> _navigateToMedicinePage() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MedicinePage()),
    );

    if (result != null && result is MedModel) {
      setState(() {
        _medications.add(result);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(19, 69, 122, 1.0),
      body: _medications.isEmpty
          ? Center(child: Text('No medications found'))
          : ListView.builder(
        itemCount: _medications.length,
        itemBuilder: (context, index) {
          final med = _medications[index];
          return Card(
            child: ListTile(
              title: Text('İlaç Adı: ${med.name}'),
              subtitle: Text(
                  'Not1: ${med.med1}\nNot2: ${med.med2}\nNot3: ${med.med3}\nNot4: ${med.med4}\nNot5: ${med.med5}'),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToMedicinePage,
        child: Icon(Icons.add),
      ),
    );
  }
}
