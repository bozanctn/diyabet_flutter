import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:diyabet/models/med_model.dart';
import 'package:diyabet/screens/medicine/medicine_form_widget.dart'; // Modüler widget için import

class MedicinePage extends StatefulWidget {
  @override
  _MedicinePageState createState() => _MedicinePageState();
}

class _MedicinePageState extends State<MedicinePage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _doseController = TextEditingController();
  final List<TextEditingController> _otherMedControllers = [
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
  ];

  String _selectedFrequency = 'Günde 1 kere';

  @override
  void dispose() {
    _nameController.dispose();
    _doseController.dispose();
    _otherMedControllers.forEach((controller) => controller.dispose());
    super.dispose();
  }

  void _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        MedModel newMed = MedModel(
          uid: user.uid,
          name: _nameController.text,
          med1: _doseController.text,
          med2: _selectedFrequency,
          med3: _otherMedControllers[0].text.isNotEmpty ? _otherMedControllers[0].text : null,
          med4: _otherMedControllers[1].text.isNotEmpty ? _otherMedControllers[1].text : null,
          med5: _otherMedControllers[2].text.isNotEmpty ? _otherMedControllers[2].text : null,
          timestamp: DateTime.now(), // Kaydedildiği zamanı ekleyelim
        );

        await MedModel.saveProfile(newMed);
        Navigator.pop(context, newMed);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(19, 69, 122, 1.0),
      appBar: AppBar(
        title: const Text('İlaç Kayıt',
          style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color.fromRGBO(19, 69, 122, 1.0),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: MedicineFormWidget(
          formKey: _formKey,
          nameController: _nameController,
          doseController: _doseController,
          otherMedControllers: _otherMedControllers,
          selectedFrequency: _selectedFrequency,
          onFrequencyChanged: (value) {
            setState(() {
              _selectedFrequency = value;
            });
          },
          onSave: _saveProfile,
        ),
      ),
    );
  }
}
