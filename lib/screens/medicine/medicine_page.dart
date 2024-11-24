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
  final TextEditingController _doseController = TextEditingController();
  final List<TextEditingController> _otherMedControllers = [
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
  ];

  String _selectedMedicine = 'Humulin-R'; // Varsayılan ilaç ismi
  String _selectedFrequency = 'Günde 1 kere'; // Varsayılan kullanım sıklığı

  @override
  void dispose() {
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
          name: _selectedMedicine,
          // İlaç adı artık dropdown'dan alınıyor
          med1: _doseController.text,
          med2: _selectedFrequency,
          med3: _otherMedControllers[0].text.isNotEmpty
              ? _otherMedControllers[0].text
              : null,
          med4: _otherMedControllers[1].text.isNotEmpty
              ? _otherMedControllers[1].text
              : null,
          med5: _otherMedControllers[2].text.isNotEmpty
              ? _otherMedControllers[2].text
              : null,
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
        title: const Text(
          'İlaç Kayıt',
          style: TextStyle(
              color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color.fromRGBO(19, 69, 122, 1.0),
        centerTitle: true,
      ),
      body: GestureDetector(
        onTap: () {
          // Klavyeyi kapatmak için boş bir alana tıklama
          FocusScope.of(context).unfocus();
        },
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Form(
                  key: _formKey,
                  child: MedicineFormWidget(
                    selectedMedicine: _selectedMedicine,
                    doseController: _doseController,
                    otherMedControllers: _otherMedControllers,
                    selectedFrequency: _selectedFrequency,
                    onMedicineChanged: (value) {
                      setState(() {
                        _selectedMedicine = value;
                      });
                    },
                    onFrequencyChanged: (value) {
                      setState(() {
                        _selectedFrequency = value;
                      });
                    },
                    onSave: _saveProfile,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: SizedBox(
        height: MediaQuery
            .of(context)
            .viewInsets
            .bottom, // Klavye yüksekliğini otomatik ekler
      ),
    );
  }
}