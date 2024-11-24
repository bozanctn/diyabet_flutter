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
          ? Center(child: Text('No medications found', style: TextStyle(color: Colors.white, fontSize: 18)))
          : ListView.builder(
        padding: const EdgeInsets.all(16.0), // Add padding around the list
        itemCount: _medications.length,
        itemBuilder: (context, index) {
          final med = _medications[index];
          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12), // Rounded corners
            ),
            elevation: 4, // Subtle shadow for depth
            margin: const EdgeInsets.symmetric(vertical: 8), // Space between cards
            child: Padding(
              padding: const EdgeInsets.all(16.0), // Padding inside the card
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'İlaç Adı: ${med.name}',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color.fromRGBO(19, 69, 122, 1.0),
                    ),
                  ),
                  SizedBox(height: 8), // Space between title and notes
                  Text(
                    'Not1: ${med.med1}',
                    style: TextStyle(color: Colors.black54),
                  ),
                  Text(
                    'Not2: ${med.med2}',
                    style: TextStyle(color: Colors.black54),
                  ),
                  Text(
                    'Not3: ${med.med3}',
                    style: TextStyle(color: Colors.black54),
                  ),
                  Text(
                    'Not4: ${med.med4}',
                    style: TextStyle(color: Colors.black54),
                  ),
                  Text(
                    'Not5: ${med.med5}',
                    style: TextStyle(color: Colors.black54),
                  ),
                ],
              ),
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
