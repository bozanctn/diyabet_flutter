import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:diyabet/models/med_model.dart';

class MedicinePage extends StatefulWidget {
  @override
  _MedicinePageState createState() => _MedicinePageState();
}

class _MedicinePageState extends State<MedicinePage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _doseController = TextEditingController();
  final TextEditingController _othermed3controller = TextEditingController();
  final TextEditingController _othermed4controller = TextEditingController();
  final TextEditingController _othermed5controller = TextEditingController();

  List<MedModel> _medications = [];
  String _selectedFrequency = 'Günde 1 kere';
  String _selectedMedicine = 'Humulin-R'; // Varsayılan ilaç ismi

  final List<String> _insulinBrands = [
    'Humulin-R',
    'Novo Nordisk Actrapid',
    'Humolog',
    'Novorapid',
    'Humulin N',
    'İnsülatard',
    'Lantus',
    'Levemir',
    'Toujou'
  ];

  @override
  void initState() {
    super.initState();
    _loadMedications();
  }

  void _loadMedications() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      List<MedModel> meds = await MedModel.getMedications(user.uid);
      setState(() {
        _medications = meds;
      });
    }
  }

  void _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      try {
        User? user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          MedModel newMed = MedModel(
            uid: user.uid,
            name: _selectedMedicine, // İlaç ismi dropdown'dan seçildi
            med1: _doseController.text, // İlk giriş, ilaç dozu
            med2: _selectedFrequency, // İkinci giriş, kullanım sıklığı
            med3: _othermed3controller.text,
            med4: _othermed4controller.text,
            med5: _othermed5controller.text,
          );

          // Yeni ilacı kaydet
          await MedModel.saveProfile(newMed);

          // Yeni ilacı önceki ekrana döndür
          Navigator.pop(context, newMed);
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Veriler yüklenirken hata oluştu')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Medicine Page'),
        backgroundColor: Color.fromRGBO(19, 69, 122, 1.0),
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20),
              color: Color.fromRGBO(19, 69, 122, 1.0),
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      DropdownButtonFormField<String>(
                        value: _selectedMedicine,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          hintText: 'İlaç Seçin',
                        ),
                        items: _insulinBrands.map((String brand) {
                          return DropdownMenuItem(
                            child: Text(brand),
                            value: brand,
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedMedicine = value!;
                          });
                        },
                      ),
                      SizedBox(height: 20),
                      TextFormField(
                        controller: _doseController,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          hintText: 'Kaç Doz Alındı',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Lütfen doz miktarını girin';
                          }
                          return null;
                        },
                        keyboardType: TextInputType.number,
                      ),
                      SizedBox(height: 20),
                      DropdownButtonFormField<String>(
                        value: _selectedFrequency,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          hintText: 'Günde Kaç Kere Kullanılıyor',
                        ),
                        items: [
                          DropdownMenuItem(
                            child: Text('Günde 1 kere'),
                            value: 'Günde 1 kere',
                          ),
                          DropdownMenuItem(
                            child: Text('Günde 2 kere'),
                            value: 'Günde 2 kere',
                          ),
                          DropdownMenuItem(
                            child: Text('Günde 3 kere'),
                            value: 'Günde 3 kere',
                          ),
                          DropdownMenuItem(
                            child: Text('Günde 4 kere'),
                            value: 'Günde 4 kere',
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedFrequency = value!;
                          });
                        },
                      ),
                      SizedBox(height: 20),
                      for (int i = 0; i < 2; i++) ...[
                        TextFormField(
                          controller: [
                            _othermed3controller,
                            _othermed4controller
                          ][i],
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            hintText: 'Diğer Ayrıntılı İlaç Bilgileri',
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'İlaç Bilgisi Eksik';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 20),
                      ],
                      Align(
                        alignment: Alignment.bottomRight,
                        child: ElevatedButton(
                          onPressed: _saveProfile,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                          ),
                          child: Text('Ekle', style: TextStyle(color: Colors.blue)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
